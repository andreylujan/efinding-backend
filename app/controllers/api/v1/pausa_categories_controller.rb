class Api::V1::PausaCategoriesController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!

end
