# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: table_columns
#
#  id                :integer          not null, primary key
#  field_name        :text
#  column_name       :text
#  position          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  relationship_name :text
#  data_type         :integer          default("text")
#  collection_name   :text
#  collection_source :integer
#  organization_id   :integer
#

class TableColumn < ApplicationRecord
  belongs_to :organization
  acts_as_list scope: [ :collection_name, :collection_source ]
  enum data_type: [ :numeric, :text, :date ]
  enum collection_source: [ :postgres, :mongo ]
end
