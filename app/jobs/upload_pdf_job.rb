# -*- encoding : utf-8 -*-
class UploadPdfJob < ApplicationJob

  queue_as :efinding_report
  require('open-uri')

  def perform(report_id)
    report = Report.find(report_id)
    report.marked_location = Location.find(report.marked_location_id)
    ac = ActionController::Base.new()
    # html = ac.render_to_string('templates/report.html.erb',
    # html = ac.render_to_string('templates/report2.html.erb',
    html = nil

    location_image = open("http://maps.googleapis.com/maps/api/staticmap?&maptype=roadmap&zoom=15&size=500x230&markers=size:" + 
      "mid%7Ccolor:blue%7C#{report.marked_location.lonlat.y},#{report.marked_location.lonlat.x}&key=AIzaSyCfbgt7XmdEbRPTXaiNq5bOvFWDVpmBx3A")
    s3 = Aws::S3::Resource.new
    location_key = "locations/#{SecureRandom.uuid}.jpg"
    bucket = s3.bucket("#{ENV['AMAZON_BUCKET']}")
    obj = bucket.object(location_key)
    obj.put(body: location_image.read)
    location_url = "#{ENV['AMAZON_CDN'].gsub('https', 'http')}#{location_key}"
    begin
      html = (ac.render_to_string('templates/' + report.creator.organization_id.to_s + '/report.html.erb',
                                  locals: { report: report, location_url: location_url })).force_encoding("UTF-8")
      pdf = WickedPdf.new.pdf_from_string(html, zoom: 0.8)
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
  end
end
