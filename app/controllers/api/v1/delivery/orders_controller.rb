class Api::V1::Delivery::OrdersController < ApplicationController
  def create
  	order_id = params.require(:order_id)
  	order_state = params.require(:order_state)
  	created_at = params.require(:order_creation_date)

  	render json: {
  		code: 200,
  		message: "successful request"
  	}, status: :ok
  end
end
