# -*- encoding : utf-8 -*-
class Api::V1::CheckinsController < ApplicationController
	before_action :doorkeeper_authorize!

	def create
		@checkin = Checkin.new user: current_user
		@checkin.data = params.require(:data)
		@checkin.arrival_lonlat = "POINT(#{params.require(:longitude)} #{params.require(:latitude)})"
		@checkin.save!
		render json: @checkin, status: :created
	end

	def update
		@checkin = current_user.checkins.last
		if @checkin.nil? or @checkin.exit_time.present?
			render json: {
				errors: [
		        status: '422',
		        detail: 'No ha hecho un checkin previo'
		      ]
		      }, status: :unprocessable_entity
		      return
		end
		
		if params.require(:data) != @checkin.data
				render json: {
				errors: [
		        status: '422',
		        detail: 'Los datos de salida no son iguales a los datos de llegada'
			      ]
			      }, status: :unprocessable_entity	
			return
		end

		@checkin.exit_lonlat = "POINT(#{params.require(:longitude)} #{params.require(:latitude)})"
		@checkin.exit_time = DateTime.now
		@checkin.save!
		render json: @checkin, status: :ok

	end
end
