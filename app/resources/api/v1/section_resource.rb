# -*- encoding : utf-8 -*-
class Api::V1::SectionResource < ApplicationResource

  attributes :name, :position, :config, :section_type
  has_many :data_parts, always_include_linkage_data: false
  add_foreign_keys :report_type_id

  def custom_links(options)
    { self: nil }
  end

  def fetchable_fields
    super
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    Section.joins(:report_type)
    .where(report_types: { organization_id: current_user.organization_id })
  end
end
