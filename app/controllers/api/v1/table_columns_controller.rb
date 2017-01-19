class Api::V1::TableColumnsController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
