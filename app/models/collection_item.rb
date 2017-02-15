# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: collection_items
#
#  id            :integer          not null, primary key
#  collection_id :integer
#  name          :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CollectionItem < ApplicationRecord
  belongs_to :collection
end
