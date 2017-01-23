# -*- encoding : utf-8 -*-
class UploadPdfJob < ApplicationJob
  queue_as :efinding_report

  def perform(report_id)
    report = Report.find(report_id)
    report.marked_location = Location.find(report.marked_location_id)
    ac = ActionController::Base.new()
    # html = ac.render_to_string('templates/report.html.erb',
    # html = ac.render_to_string('templates/report2.html.erb',
    html = nil
    begin
      html = (ac.render_to_string('templates/' + report.creator.organization_id.to_s + '/report.html.erb',
                                  locals: { report: report })).force_encoding("UTF-8")
      pdf = WickedPdf.new.pdf_from_string(html, zoom: 0.8)
      file = Tempfile.new('pdf', encoding: 'ascii-8bit')
    rescue ActionView::MissingTemplate => e
      return
    end

    begin
      file.write(pdf)

      report.pdf = file
      report.pdf_uploaded = true
      report.save!
    ensure
      file.close
      file.unlink   # deletes the temp file
    end
  end
end
