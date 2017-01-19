class Api::V1::CompaniesController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
