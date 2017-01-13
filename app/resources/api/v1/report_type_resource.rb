# -*- encoding : utf-8 -*-
class Api::V1::ReportTypeResource < ApplicationResource
  attributes :name, :title_field, :subtitle_field
  has_many :sections
  has_many :report_columns

  def custom_links(options)
    { self: nil }
  end

  def fetchable_fields
    super
  end
end
