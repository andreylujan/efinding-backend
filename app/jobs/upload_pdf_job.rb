# -*- encoding : utf-8 -*-
class UploadPdfJob < ApplicationJob

  queue_as :etodo_report
  require('open-uri')

  def perform(report_id)
    if not Report.exists? report_id
      return
    end
    report = Report.find(report_id)
    ac = ActionController::Base.new()
    html = nil

    report.ignore_pdf = true
    report.images.each do |image|
      image.fix_rotation
      image.save!
    end
    report.pdfs.destroy_all
    report.report_type.pdf_templates.each do |template|
      html = (ac.render_to_string(inline: template.template,
                                  locals: { report: report })).force_encoding("UTF-8")
      pdf = WickedPdf.new.pdf_from_string(html, zoom: 0.75)
      file = Tempfile.new('pdf', encoding: 'ascii-8bit')

      begin
        file.write(pdf)
        # report.pdfs.destroy_all
        pdf = Pdf.create! report_id: report.id, pdf_template_id: template.id
        report.pdf_uploaded = true
        pdf.uploaded = true
        pdf.pdf = file
        pdf.save!
        report.save!
        MailerJob.set(wait: 20.seconds, queue: ENV['REPORT_QUEUE'] || 'etodo_report').perform_later(report_id)
      ensure
        file.close
        file.unlink   # deletes the temp file
      end
    end

    report.ignore_pdf = false
  end
end
