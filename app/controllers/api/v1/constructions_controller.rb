class Api::V1::ConstructionsController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
