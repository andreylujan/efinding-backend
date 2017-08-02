# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: data_part_values
#
#  id                 :integer          not null, primary key
#  collection_item_id :integer
#  data_part_id       :integer          not null
#  report_id          :uuid
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class DataPartValue < ApplicationRecord
  belongs_to :report
  belongs_to :collection_item
  belongs_to :data_part

  validates :report, presence: true
  validates :data_part, presence: true, uniqueness: { scope: :report }
end
