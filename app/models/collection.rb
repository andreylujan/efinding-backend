# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: collections
#
#  id                   :integer          not null, primary key
#  name                 :text
#  parent_collection_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organization_id      :integer
#

class Collection < ApplicationRecord
	belongs_to :parent_collection, 
		class_name: :Collection, foreign_key: :parent_collection_id
	belongs_to :organization
	belongs_to :collection
	has_many :collection_items
	validates :organization, presence: true
	validates :name, presence: true, uniqueness: { scope: :organization }
end
