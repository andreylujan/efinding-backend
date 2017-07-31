# -*- encoding : utf-8 -*-
class Api::V1::Idd::ReportSummaryResource < JSONAPI::Resource
  attributes :email, :name, :phone, :num_reports
end
