class Api::V1::InspectionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!
end
