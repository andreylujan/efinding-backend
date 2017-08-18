class Api::V1::PdfResource < ApplicationResource
	attributes :pdf_url
	add_foreign_keys :report_id
end
