# -*- encoding : utf-8 -*-
class ChecklistPdfJob < ApplicationJob

  queue_as :efinding_report
  require('open-uri')

  def perform(checklist_id)
    checklist = ChecklistReport.find(checklist_id)
    if checklist.location_id
      checklist.location = Location.find(checklist.location_id)
    end
 
    ac = ActionController::Base.new()
    # html = ac.render_to_string('templates/report.html.erb',
    # html = ac.render_to_string('templates/report2.html.erb',
    html = nil

    checklist.ignore_pdf = true

    if checklist.location.present?
      location_image = open("http://maps.googleapis.com/maps/api/staticmap?&maptype=roadmap&zoom=15&size=400x250&markers=size:" + 
        "mid%7Ccolor:green%7C#{checklist.location.lonlat.y},#{checklist.location.lonlat.x}&key=AIzaSyCfbgt7XmdEbRPTXaiNq5bOvFWDVpmBx3A")
      checklist.location_image = location_image
      checklist.save!
    end

    checklist.ignore_pdf = false
    
    begin
      html = (ac.render_to_string('templates/' + checklist.creator.organization_id.to_s + '/checklist.html.erb',
                                  locals: { checklist: checklist })).force_encoding("UTF-8")
      pdf = WickedPdf.new.pdf_from_string(html, zoom: 0.8)
      file = Tempfile.new('pdf', encoding: 'ascii-8bit')
      html_file = Tempfile.new('html', encoding: 'UTF-8')
    rescue ActionView::MissingTemplate => e
      return
    end

    begin
      file.write(pdf)

      checklist.pdf = file
      checklist.pdf_uploaded = true
      html_file.write(html)
      checklist.save!
      checklist.html = html_file
      checklist.save!
    ensure
      file.close
      file.unlink   # deletes the temp file
    end
  end
end
