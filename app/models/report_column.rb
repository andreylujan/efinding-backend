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
#  data_type         :integer          default(1)
#
# Indexes
#
#  index_report_columns_on_report_type_id  (report_type_id)
#
# Foreign Keys
#
#  fk_rails_2705d09e60  (report_type_id => report_types.id)
#

class ReportColumn < ApplicationRecord
  belongs_to :report_type
  acts_as_list scope: :report_type
  enum data_type: [ :numeric, :text, :date ]
end
