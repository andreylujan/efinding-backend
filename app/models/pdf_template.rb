# == Schema Information
#
# Table name: pdf_templates
#
#  id             :integer          not null, primary key
#  template       :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name           :text
#  report_type_id :integer          not null
#

class PdfTemplate < ApplicationRecord
  belongs_to :report_type
  has_many :report_types, foreign_key: :default_pdf_template_id, dependent: :nullify
  has_many :pdfs, dependent: :destroy
end
