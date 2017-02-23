require 'jsonapi-serializers'

class CsvUploadSerializer < ApplicationSerializer
	def meta
		object.meta
	end
end