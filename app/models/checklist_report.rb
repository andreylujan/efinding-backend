# == Schema Information
#
# Table name: checklist_reports
#
#  id              :uuid             not null, primary key
#  report_type_id  :integer          not null
#  construction_id :integer          not null
#  creator_id      :integer          not null
#  location_id     :integer          not null
#  pdf             :text
#  pdf_uploaded    :boolean          default(FALSE), not null
#  deleted_at      :datetime
#  html            :text
#  location_image  :text
#  checklist_data  :json             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  code            :integer
#  checklist_id    :integer
#  started_at      :datetime
#

class ChecklistReport < ApplicationRecord
  belongs_to :report_type
  belongs_to :construction
  belongs_to :location
  belongs_to :checklist
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  has_and_belongs_to_many :users

  validates :report_type, presence: true
  validates :construction, presence: true
  validates :location, presence: true
  validates :creator, presence: true
  validates :code, presence: true
  validates :id, uniqueness: true

  mount_uploader :pdf, PdfUploader
  mount_uploader :html, HtmlUploader
  mount_uploader :location_image, ImageUploader

  accepts_nested_attributes_for :location
  acts_as_paranoid

  after_commit :generate_pdf

  attr_accessor :ignore_pdf

  before_validation(on: :create) do
    self.code = next_seq unless attribute_present? :code
  end

  def generate_pdf
    if not @ignore_pdf and not self.pdf_uploaded?
      regenerate_pdf
    end
  end

  def regenerate_pdf(force_random = false)
    if force_random
      update_columns pdf: nil, pdf_uploaded: false
    end
    ChecklistPdfJob.set(queue: ENV['REPORT_QUEUE'] || 'echeckit_report').perform_later(self.id.to_s)
  end

  def formatted_created_at
    created_at.strftime("%d/%m/%Y %R")
  end

  private
  def next_seq
  	result = ChecklistReport.connection.execute("SELECT nextval('checklist_reports_code_seq')")
  	result[0]['nextval']
  end


end
