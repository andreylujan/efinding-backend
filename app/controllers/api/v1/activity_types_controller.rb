# -*- encoding : utf-8 -*-
class Api::V1::ActivityTypesController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
	def custom_links(options)
	  { self: nil }
	end
end
