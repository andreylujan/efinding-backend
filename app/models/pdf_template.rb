# == Schema Information
#
# Table name: pdf_templates
#
#  id             :integer          not null, primary key
#  template       :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  title          :text
#  report_type_id :integer          not null
#  html           :text
#

class PdfTemplate < ApplicationRecord
  belongs_to :report_type
end
