# -*- encoding : utf-8 -*-
class UploadPdfJob < ApplicationJob

  queue_as :efinding_report
  require('open-uri')

  def perform(report_id)
    report = Report.find(report_id)
    if report.initial_location_id
      report.initial_location = Location.find(report.initial_location_id)
    end
    if report.final_location_id
      report.final_location = Location.find(report.final_location_id)
    end
    ac = ActionController::Base.new()
    # html = ac.render_to_string('templates/report.html.erb',
    # html = ac.render_to_string('templates/report2.html.erb',
    html = nil

    report.ignore_pdf = true

    map_type = "road_map"
    initial_location = report.initial_location

    if report.creator.organization_id == 3
      map_type = "satellite"
      if initial_location.present?
        initial_location.lonlat = "POINT(#{report.station.coordinates[0]} #{report.station.coordinates[1]})"
      end
    end

    if initial_location.present?
      initial_location_image = open("http://maps.googleapis.com/maps/api/staticmap?&maptype=#{map_type}&zoom=15&size=400x250&markers=size:" + 
        "mid%7Ccolor:green%7C#{initial_location.lonlat.y},#{initial_location.lonlat.x}&key=AIzaSyAxdoh8VjK53CCCYNmGx0RGuompeK-ejzc")
      file = Tempfile.new('initial_location_image')
      file.binmode
      file.write(initial_location_image.read)
      report.initial_location_image = file
      report.save!
      file.close
      file.unlink
    end

    if report.final_location.present?
      final_location_image = open("http://maps.googleapis.com/maps/api/staticmap?&maptype=#{map_type}&zoom=15&size=400x250&markers=size:" + 
        "mid%7Ccolor:orange%7C#{report.final_location.lonlat.y},#{report.final_location.lonlat.x}&key=AIzaSyAxdoh8VjK53CCCYNmGx0RGuompeK-ejzc")
      file = Tempfile.new('final_location_image')
      file.binmode
      file.write(final_location_image.read)
      report.final_location_image = file
      report.save!
      file.close
      file.unlink
    end
    
    report.ignore_pdf = false
    
    begin
      html = (ac.render_to_string('templates/' + report.creator.organization_id.to_s + '/report.html.erb',
                                  locals: { report: report })).force_encoding("UTF-8")
      pdf = WickedPdf.new.pdf_from_string(html, zoom: 0.75)
      file = Tempfile.new('pdf', encoding: 'ascii-8bit')
      html_file = Tempfile.new('html', encoding: 'UTF-8')
    rescue ActionView::MissingTemplate => e
      return
    end

    begin
      file.write(pdf)

      report.pdf = file
      report.pdf_uploaded = true
      html_file.write(html)
      report.save!
      report.html = html_file
      report.save!
    ensure
      file.close
      file.unlink   # deletes the temp file
    end

    begin
      report.inspection.regenerate_pdf(true)
    rescue => e
    end
  end
end
