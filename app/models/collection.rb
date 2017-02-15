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
	belongs_to :collection
	belongs_to :organization
	has_many :collection_items
	validates :organization, presence: true
	validates :name, presence: true, uniqueness: { scope: :organization }
end
