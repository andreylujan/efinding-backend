class Api::V1::Delivery::OrdersController < ApplicationController
  def create
  	render json: {
  		code: 200,
  		message: "successful request"
  	}, status: :ok
  end
end
