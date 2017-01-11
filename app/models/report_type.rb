# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: report_types
#
#  id              :integer          not null, primary key
#  name            :text
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  title_field     :text
#  subtitle_field  :text
#  has_nav_button  :boolean          default(FALSE)
#

class ReportType < ApplicationRecord
  belongs_to :organization
  has_many :sections
  has_many :report_columns, -> { order(position: :asc) }
end
