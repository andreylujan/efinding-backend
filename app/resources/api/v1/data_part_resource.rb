# -*- encoding : utf-8 -*-
class Api::V1::DataPartResource < ApplicationResource
  attributes :name, :icon, :required, :config,
    :data_part_type, :position

  add_foreign_keys :section_id, :collection_id, :list_id
  has_one :collection
  has_many :data_parts

  def data_part_type
    @model.type.underscore
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    DataPart.joins(section: :report_type)
    .where(report_types: { organization_id: current_user.organization_id })

  end

  def custom_links(options)
    { self: nil }
  end

end
