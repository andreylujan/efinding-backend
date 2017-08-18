class Api::V1::PdfTemplateResource < ApplicationResource
	attributes :template, :name
	add_foreign_keys :report_type_id
end
