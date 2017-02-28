# -*- encoding : utf-8 -*-
class Api::V1::ConstructionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

  def update
    params.permit!
    if personnel = params.dig("data", "attributes", "construction_personnel_attributes")
      personnel.each do |p|
        p["construction_id"] = params[:id]
      end
    end

    super
  end

  def context
    {
      current_user: current_user,
      company_id: params[:company_id]
    }
  end

end
