# -*- encoding : utf-8 -*-
class MailerJob < ApplicationJob

  queue_as :etodo_report
  require('open-uri')

  def perform(report_id)
    if not Report.exists? report_id
      return
    end
    report = Report.find(report_id)
    p "report MailerJOB"
    UserMailer.manflas_email(report).deliver
  end
end
