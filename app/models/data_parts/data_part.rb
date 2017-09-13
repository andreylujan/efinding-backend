# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: data_parts
#
#  id            :integer          not null, primary key
#  type          :text             not null
#  name          :text             not null
#  icon          :text
#  required      :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  config        :jsonb            not null
#  position      :integer          default(0), not null
#  detail_id     :integer
#  collection_id :integer
#  list_id       :integer
#  assigns_user  :boolean          default(FALSE), not null
#

class DataPart < ApplicationRecord
  CONFIG_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'data_parts', 'config.json_schema').to_s
  acts_as_list scope: :list
  belongs_to :collection
  has_many :section_data_parts, dependent: :destroy
  has_many :sections, through: :section_data_parts
  has_many :data_parts, class_name: :DataPart, foreign_key: :list_id
  belongs_to :list, class_name: :List, foreign_key: :list_id
  validates :config, json: { schema: CONFIG_JSON_SCHEMA }
end
