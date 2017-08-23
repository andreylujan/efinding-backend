# -*- encoding : utf-8 -*-
class UploadPdfJob < ApplicationJob

  queue_as :efinding_report
  require('open-uri')

  def perform(report_id)
    if not Report.exists? report_id
      return
    end
    report = Report.find(report_id)
    # if report.initial_location_id
    #   report.initial_location = Location.find(report.initial_location_id)
    # end
    # if report.final_location_id
    #   report.final_location = Location.find(report.final_location_id)
    # end
    ac = ActionController::Base.new()
    # html = ac.render_to_string('templates/report.html.erb',
    # html = ac.render_to_string('templates/report2.html.erb',
    html = nil

    report.ignore_pdf = true
    report.pdfs.destroy_all
    report.ignore_pdf = false
    report.report_type.pdf_templates.each do |template|
      html = (ac.render_to_string(inline: template.template,
                                  locals: { report: report })).force_encoding("UTF-8")
      pdf = WickedPdf.new.pdf_from_string(html, zoom: 0.75)
      file = Tempfile.new('pdf', encoding: 'ascii-8bit')
      html_file = Tempfile.new('html', encoding: 'UTF-8')
      

      begin
        file.write(pdf)
        # report.pdfs.destroy_all
        pdf = Pdf.find_or_initialize_by(report_id: report.id, pdf_template_id: template.id)
        report.pdf_uploaded = true
        pdf.uploaded = true
        html_file.write(html)
        pdf.pdf = file
        pdf.html = html_file
        pdf.save!
        report.save!
      ensure
        file.close
        file.unlink   # deletes the temp file
      end
    end



    begin
      report.inspection.regenerate_pdf(true)
    rescue => e
    end
  end
end
