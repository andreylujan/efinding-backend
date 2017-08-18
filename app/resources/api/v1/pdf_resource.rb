class Api::V1::PdfResource < ApplicationResource
	attributes :pdf_url, :pdf_html
	add_foreign_keys :report_id

	def pdf_html
		if @model.uploaded?
			"<input ng-if=\"report[‘pdfUploaded’]\" class=\"text-center\" type=\"image\" src=\"https://s3-sa-east-1.amazonaws.com/efinding/icons/PDF.png\" uib-tooltip=\"Descargar PDF\" tooltip-placement=\"bottom\" style=\"width: 15px\" data-pdf=\"#{@model.pdf_url}\" ng-click=\"downloadPdf($event)\"/>"
		else
			"<input ng-if=\"!report[‘pdfUploaded’]\" class=\"text-center\" type=\"image\" src=\"http://dhg7r6mxe01qf.cloudfront.net/icons/admin/denied2.png\" uib-tooltip=\"PDF no disponible\" tooltip-placement=\"bottom\" style=\"width: 20px;\" />"
		end
	end
end
