# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: collection_items
#
#  id                  :integer          not null, primary key
#  collection_id       :integer
#  name                :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_item_id      :integer
#  code                :text
#  parent_code         :text
#  position            :integer
#  resource_owner_id   :integer
#  resource_owner_type :text
#

class CollectionItem < ApplicationRecord
  belongs_to :collection
  acts_as_list scope: :collection
  belongs_to :parent_item, class_name: :CollectionItem,
  	foreign_key: :parent_item_id

  belongs_to :resource_owner, polymorphic: true
  validates :collection, presence: true
  validates :name, presence: true
  validates :code, presence: true
  validates_uniqueness_of :code, scope: :collection
  validates_uniqueness_of :name, scope: :collection


  def to_csv(csv_columns)
  	csv_columns.map do |column_name|
  		self.send column_name
  	end
  end
end
