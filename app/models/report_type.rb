# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: report_types
#
#  id                         :integer          not null, primary key
#  name                       :text
#  organization_id            :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  title_field                :text
#  subtitle_field             :text
#  has_pdf                    :boolean          default(TRUE), not null
#  initial_state_id           :integer
#  default_dynamic_attributes :jsonb            not null
#  default_title              :text             default("Sin título"), not null
#  default_subtitle           :text             default("Sin subtítulo"), not null
#

class ReportType < ApplicationRecord
  belongs_to :organization
  has_many :reports
  has_many :checklist_reports
  validates :organization, presence: true
  belongs_to :initial_state, class_name: :State, foreign_key: :initial_state_id
  # validates :initial_state, presence: true
  has_many :states
  accepts_nested_attributes_for :states
  has_many :pdf_templates
end
