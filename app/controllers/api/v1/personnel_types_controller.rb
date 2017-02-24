class Api::V1::PersonnelTypesController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
