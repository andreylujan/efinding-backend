class Api::V1::BatchUploadsController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
