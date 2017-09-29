# -*- encoding : utf-8 -*-
class ScheduledOrderJob < ApplicationJob
  queue_as :efinding_push

  def perform(report_id)

    report = Report.find_by_id(report_id)
    if report.nil?
      return
    end
    
    user = report.creator

    if user.nil?
      return
    end

    apns_app_name = ENV["APNS_APP_NAME"]
    gcm_app_name = ENV["GCM_APP_NAME"]

    conn = Faraday.new(:url => ENV["PUSH_ENGINE_HOST"])
    params = {
      alert: "Pedido programado",
      data: {
        message: "Hay un pedido programado para esta fecha",
        title: "Pedido programado",
        report_id: report.id.to_s
      },
      gcm_app_name: gcm_app_name,
      apns_app_name: apns_app_name
    }

    devices = user.devices
    registration_ids = devices.where("registration_id is not null").map { |r| r.registration_id }
    device_tokens = devices.where("device_token is not null").map { |r| r.device_token }


    if registration_ids.length > 0 or device_tokens.length > 0
      body = params.merge({
                            registration_ids: registration_ids,
                            device_tokens: device_tokens
      })
      response = conn.post do |req|
        req.url '/notifications'
        req.headers['Content-Type'] = 'application/json'
        req.body = body.to_json
      end
    end
  end
end