# -*- encoding : utf-8 -*-
class Api::V1::CollectionItemResource < ApplicationResource
  attributes :name, :code, :position
  add_foreign_keys :parent_item_id, :collection_id
  has_one :collection
  has_one :parent_item

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    CollectionItem.joins(:collection)
    .where(collections: { organization_id: current_user.organization_id })
  end
end
