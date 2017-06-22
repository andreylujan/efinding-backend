# -*- encoding : utf-8 -*-
class Api::V1::ReportTypeResource < ApplicationResource
  attributes :name, :title_field, :subtitle_field
  has_many :sections
  has_many :states
  has_one :initial_state
  add_foreign_keys :organization_id

  def custom_links(options)
    { self: nil }
  end

  def fetchable_fields
    super
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    ReportType.where(organization_id: current_user.organization_id)
  end
end
