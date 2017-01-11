# -*- encoding : utf-8 -*-
class Api::V1::DevicesController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!

  def context
    {current_user: current_user}
  end  
end
