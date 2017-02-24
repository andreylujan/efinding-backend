class Api::V1::PersonnelController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
