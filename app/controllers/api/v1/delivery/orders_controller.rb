class Api::V1::Delivery::OrdersController < ApplicationController
  def create
    order_id = params.require(:order_id)
    order_state = params.require(:order_state)["order_state_description"].downcase
    created_at = params.require(:order_creation_date)
    report = Report.where("dynamic_attributes->'49'->>'text' = '#{order_id}'").first

    products = params["detail"].map do |detail|
      {
        quantity: detail["order_product_quantity"],
        size: detail["order_product_size"],
        name: detail.dig("product_detail", "product_name"),
        description: detail.dig("product_detail", "product_description"),
        price: detail.dig("product_detail", "product_price"),
        image: detail.dig("product_detail", "product_image"),
        id: detail.dig("product_detail", "product_id")
      }
    end

    user = params.require(:user_info)
    if report.nil?
      report = Report.new id: SecureRandom.uuid,
        creator_id: 68,
        state: "unchecked",
        finished: true,
        report_type_id: 6
    else
      state = nil
      if order_state == "pedido creado"
        state = "unchecked"
      elsif order_state == "pedido pagado"
        state = "awaiting_delivery"
      elsif order_state == "pedido cancelado"
        state = "canceled"
      end
      report.state = state
    end
    items = []
    products.each do |product|
      desc = product[:quantity].to_s + " " + product[:name]
      if product[:size].present?
        desc = desc + "\n" + "Tamaño #{product[:size]}"
      end
      items << {
        id: product[:id].to_s,
        name: desc
      }
    end

    report.dynamic_attributes["47"] = {
      sections: [
        {
          id: order_id.to_s,
          name: nil,
          items: items
        }
      ]
    }

    report.dynamic_attributes["49"] = {
      text: order_id.to_s
    }

    user_name = user.dig("user_name")
    if user.dig("user_last_name")
      user_name = user_name + " " + user.dig("user_last_name")
    end
    report.dynamic_attributes["50"] = {
      text: user_name
    }

    report.dynamic_attributes["51"] = {
      text: user.dig("user_phone") || "Sin número de teléfono"
    }

    report.dynamic_attributes["title"] = user_name
    report.dynamic_attributes["subtitle"] = "Pedido #{order_id}"

    report.save!


    render json: {
      code: 200,
      message: "successful request"
    }, status: :ok
  end
end
