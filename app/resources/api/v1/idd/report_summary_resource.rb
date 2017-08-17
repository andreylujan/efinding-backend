# -*- encoding : utf-8 -*-
class Api::V1::Idd::ReportSummaryResource < JSONAPI::Resource
  attributes :email, :num_reports, :name, :phone
end
