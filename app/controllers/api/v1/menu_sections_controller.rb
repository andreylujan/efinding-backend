class Api::V1::MenuSectionsController < Api::V1::JsonApiController

	before_action :doorkeeper_authorize!

	
end
