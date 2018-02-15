# -*- encoding : utf-8 -*-
class SendTaskJob < ApplicationJob
  queue_as :etodo_push

  def perform(report_id)

    report = Report.find_by_id(report_id)
    if report.nil?
      return
    end

    user = report.assigned_user

    if user.nil?
      return
    end

    apns_app_name = ENV["APNS_APP_NAME"]
    gcm_app_name = ENV["GCM_APP_NAME"]

    conn = Faraday.new(:url => ENV["PUSH_ENGINE_HOST"])
    if report.organization_id == 12
      text_title = "Reporte enviado"
      text_body = "Se ha enviado su reporte"
      text_alert = "Reporte enviado"
    else
      text_title = "Tarea asignada"
      text_body = "Se le ha asignado una tarea"
      text_alert = "Tarea asignada"
    end
    params = {
      alert: text_alert,
      data: {
        body: text_body,
        title: text_title,
        report_id: report.id.to_s
      },
      notification_hash: {
        body: text_body,
        title: text_title,
        icon: "logo"
      },
      gcm_app_name: gcm_app_name,
      apns_app_name: apns_app_name
    }

    devices = user.devices
    registration_ids = devices.where("registration_id is not null").map { |r| r.registration_id }
    device_tokens = devices.where("device_token is not null").map { |r| r.device_token }
    amazon_devices = devices.where.not(endpoint_arn: nil)
    sns = Aws::SNS::Client.new(region: "us-west-2")
    message = { GCM: { notification: { title: text_title, body: text_body, icon: "logo" } }.to_json }.to_json

    amazon_devices.each do |device|
      begin
        sns.publish(message: message, target_arn: device.endpoint_arn, message_structure: "json")
      rescue Aws::SNS::Errors::EndpointDisabled, Aws::SNS::Errors::InvalidParameter
        device.destroy!
      end
    end

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
