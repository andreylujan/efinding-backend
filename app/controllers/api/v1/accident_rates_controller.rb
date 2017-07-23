class Api::V1::AccidentRatesController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
