# -*- encoding : utf-8 -*-
class ChangeStateJob < ApplicationJob
  queue_as :efinding_report

  def perform(report_id)
    report = Report.find(report_id)
    if report.state_id == 18 || report.state_id == 16

      title = report.dynamic_attributes.dig("78", "value")
      email = report.dynamic_attributes.dig("81", "value")
      suffix = report.state_id == 18 ? "archivado, ya que es competencia de otro ente" : "resuelto"
      message = "El reclamo #{title.downcase} ha sido #{suffix}"

      conn = Faraday.new(:url => "http://ec2-54-88-114-83.compute-1.amazonaws.com")

      begin
        response = conn.post do |req|
          req.url '/idd/index.php/api/reclamo/send_push_notification'
          req.body = {
            email: email,
            title: title,
            message: message
          }
        end
        RequestLog.create! organization_id: 6, url: "http://ec2-54-88-114-83.compute-1.amazonaws.com/idd/index.php/api/reclamo/send_push_notification", status_code: response.status,
          response_body: response.body
      rescue => e
        RequestLog.create! organization_id: 6, url: "http://ec2-54-88-114-83.compute-1.amazonaws.com/idd/index.php/api/reclamo/send_push_notification", status_code: 0,
          error_messages: [ e.message ]
      end
    end
  end
end
