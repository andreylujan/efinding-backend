# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: sections
#
#  id           :integer          not null, primary key
#  position     :integer
#  name         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  section_type :integer
#  config       :jsonb            not null
#  state_id     :integer
#

class Section < ApplicationRecord
  CONFIG_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'sections', 'config.json_schema').to_s

  belongs_to :state
  acts_as_list scope: :state
  has_many :section_data_parts, -> { order(position: :asc) }
  has_many :data_parts, through: :section_data_parts
  enum section_type: [ :location, :gallery, :data_parts ]

  validates :config, json: { schema: CONFIG_JSON_SCHEMA }
end
