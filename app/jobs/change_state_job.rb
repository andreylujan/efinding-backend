# -*- encoding : utf-8 -*-
class ChangeStateJob < ApplicationJob
  queue_as :efinding_report

  def perform(report_id)

    report = Report.find(report_id)
    order_id = report.dynamic_attributes.dig("49", "text").to_i
    state = ""
    message = nil
    Rails.logger.info "Estado : #{report.state}"
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
    elsif report.state == "awaiting_delivery"
      state = "Pendiente de retiro"
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
    begin
      response = conn.post do |req|
        req.url '/delivery_api/public/index.php/api/v1/detail_change_state'
        req.headers['Content-Type'] = 'application/json'
        req.body = body.to_json
      end
      RequestLog.create!(
        organization_id: 4,
        url: "http://ec2-54-88-114-83.compute-1.amazonaws.com/delivery_api/public/index.php/api/v1/detail_change_state",
        status_code: response.status,
      response_body: response.body)
    rescue => e
      RequestLog.create!(
        organization_id: 4,
        url: "http://ec2-54-88-114-83.compute-1.amazonaws.com/delivery_api/public/index.php/api/v1/detail_change_state",
        status_code: 0,
        error_messages: {
          message: e.message
      })
    end

    if report.state = "awaiting_delivery"
      Rails.logger.info "REPORTS PUSH: #{report.state}"

      Rails.logger.info "ORDER STATE Pendiente de retiro - creator_id: #{report.creator_id}"
      SendTaskJob.set(wait: 1.second).perform_later(report.id.to_s,
                                                  "Pedido Pendiente de retiro",
                                                 "El pedido #{order_id} está Pendiente de retiro")

    end

    if report.state == "accepted"
      conn = Faraday.new(:url => "http://ec2-54-88-114-83.compute-1.amazonaws.com")
      body = {
        id_order: order_id,
        state: state
      }
      begin
        response = conn.post do |req|
          req.url '/delivery_api/public/index.php/pago/pagar'
          req.body = {
            order_id: order_id
          }
        end
        RequestLog.create!(
          organization_id: 4,
          url: "http://ec2-54-88-114-83.compute-1.amazonaws.com/delivery_api/public/index.php/pago/pagar",
          status_code: response.status,
        response_body: response.body)
      rescue => e
        RequestLog.create!(
          organization_id: 4,
          url: "http://ec2-54-88-114-83.compute-1.amazonaws.com/delivery_api/public/index.php/pago/pagar",
          status_code: 0,
          error_messages: {
            message: e.message
        })
      end
    end
  end
end
