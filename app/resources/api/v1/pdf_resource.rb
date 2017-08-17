class Api::V1::PdfResource < JSONAPI::Resource
	attributes :pdf_url, :title
	add_foreign_keys :organization_id
end
