# -*- encoding : utf-8 -*-
class Api::V1::ActivityTypeResource < ApplicationResource
	attributes :name

	def custom_links(options)
	  { self: nil }
	end
end
