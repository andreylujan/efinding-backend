# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: collection_items
#
#  id             :integer          not null, primary key
#  collection_id  :integer
#  name           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  parent_item_id :integer
#  code           :text
#  parent_code    :text
#

class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :parent_item, class_name: :CollectionItem,
  	foreign_key: :parent_item_id

  validates :collection, presence: true
  validates :name, presence: true, uniqueness: { scope: :collection }
  validates :code, presence: true, uniqueness: { scope: :collection }

  def to_csv(csv_columns)
  	csv_columns.map do |column_name|
  		self.send column_name
  	end
  end
end
