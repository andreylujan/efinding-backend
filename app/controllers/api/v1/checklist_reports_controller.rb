class Api::V1::ChecklistReportsController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!
end
