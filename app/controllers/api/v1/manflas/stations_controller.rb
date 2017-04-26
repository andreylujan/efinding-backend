class Api::V1::Manflas::StationsController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
