# -*- encoding : utf-8 -*-
class ChangeStateJob < ApplicationJob
  queue_as :efinding_report

  def perform(report_id)

    report = Report.find(report_id)
    order_id = report.dynamic_attributes.dig("49", "text").to_i
    state = ""
    message = nil
    if report.state == "accepted"
      state = "pedido aceptado"
    elsif report.state == "rejected"
      state = "pedido rechazado"
      message = report.get_message
    elsif report.state == "confirming_suggestions"
      state = "pedido con observacion"
      message = report.get_message
    elsif report.state == "delivering"
      state = "pedido en camino"
    elsif report.state == "delivered"
      state = "pedido entregado"
    else
      return
    end
    conn = Faraday.new(:url => "http://ec2-54-88-114-83.compute-1.amazonaws.com")
    body = {
      id_order: order_id,
      state: state
    }
    if message.present?
      body[:message] = message
    end
    response = conn.post do |req|
      req.url '/delivery_api/public/index.php/api/v1/detail_change_state'
      req.headers['Content-Type'] = 'application/json'
      req.body = body.to_json
    end
  end
end
