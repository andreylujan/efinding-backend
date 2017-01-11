# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: report_columns
#
#  id                :integer          not null, primary key
#  field_name        :text
#  column_name       :text
#  position          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  report_type_id    :integer          not null
#  relationship_name :text
#  data_type         :integer          default("text")
#

class ReportColumn < ApplicationRecord
  belongs_to :report_type
  acts_as_list scope: :report_type
  enum data_type: [ :numeric, :text, :date ]
end
