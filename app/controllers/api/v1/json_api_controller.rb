# -*- encoding : utf-8 -*-
class Api::V1::JsonApiController < ApplicationController

  include JSONAPI::ActsAsResourceController

  def create
  	format_json
  	super
  end

  def update
  	format_json
  	super
  end

  protected

  def format_json
  	if params[:data].nil?

  		params[:data] = {}

  		if params[:id].present?
  			params[:data][:id] = params[:id].to_s
  			params.delete(:id)
  		end

  		params[:data][:attributes] = params.except(:action, :controller, :data)
  		params[:data][:attributes].each do |key, value|
  			params.delete(key)
  		end
  		params[:data][:type] = controller_name
  	end
  end

  def context
    {current_user: current_user}
  end  
  
end
