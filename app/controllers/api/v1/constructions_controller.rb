class Api::V1::ConstructionsController < Api::V1::JsonApiController
	before_action :doorkeeper_authorize!

	def context
    {
      current_user: current_user,
      company_id: params[:company_id]
    }
  	end

end
