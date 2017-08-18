class MigrateExistingPdfs < ActiveRecord::Migration[5.0]
  def change
    add_column :pdfs, :html, :text
  	Organization.all.each do |organization|
  	  if File.exists? "app/views/templates/#{organization.id}/report.html.erb"
  	  	report_type = organization.default_report_type.present? ? organization.default_report_type : organization.report_types.first
  	  	f = File.open("app/views/templates/#{organization.id}/report.html.erb", "r")
  	  	pdf_template = PdfTemplate.new report_type: report_type, template: f.read, name: report_type.name
  	  	f.close
  	  	pdf_template.save!
  	  	report_type.default_pdf_template = pdf_template
  	  	report_type.save!
  	  	Report.joins(:state).where(states: { report_type_id: report_type.id }).each do |report|
  	  	  if report.pdf_uploaded?
  	  	  	pdf = Pdf.new report: report, pdf_template: pdf_template
  	  	  	pdf.save!
            pdf.update_column :pdf, report[:pdf]
            pdf.update_column :html, report[:html]
  	  	  end
  	  	end
  	  end
  	end
  end
end
