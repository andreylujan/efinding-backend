# -*- encoding : utf-8 -*-
class InspectionPdfJob < ApplicationJob

  queue_as :efinding_report

  def perform(inspection_id)
    inspection = Inspection.find(inspection_id)
    
    ac = ActionController::Base.new()
    
    begin
      html = (ac.render_to_string('templates/' + inspection.creator.organization_id.to_s + '/inspection.html.erb',
                                  locals: { inspection: inspection })).force_encoding("UTF-8")
      pdf = WickedPdf.new.pdf_from_string(html, zoom: 0.8)
      file = Tempfile.new('pdf', encoding: 'ascii-8bit')
      # html_file = Tempfile.new('html', encoding: 'UTF-8')
    rescue ActionView::MissingTemplate => e
      return
    end

    begin
      file.write(pdf)

      inspection.pdf = file
      inspection.pdf_uploaded = true
      # html_file.write(html)
      inspection.save!
      # report.html = html_file
      # report.save!
    ensure
      file.close
      file.unlink   # deletes the temp file
    end
  end
end
