# -*- encoding : utf-8 -*-
class Api::V1::CollectionResource < ApplicationResource
  attributes :name
  has_one :collection
  has_many :collection_items
  add_foreign_keys :parent_collection_id, :collection_id
  
  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    Collection.where(organization: current_user.organization)
  end

  before_save do
   	@model.organization = context[:current_user].organization if @model.new_record?
  end
end
