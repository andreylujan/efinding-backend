# == Schema Information
#
# Table name: pdfs
#
#  id              :integer          not null, primary key
#  pdf             :text
#  pdf_template_id :integer          not null
#  report_id       :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Pdf < ApplicationRecord
  belongs_to :pdf_template
  belongs_to :report
  mount_uploader :pdf, PdfUploader
end
