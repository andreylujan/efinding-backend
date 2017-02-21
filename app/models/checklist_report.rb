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

  accepts_nested_attributes_for :location

  before_validation(on: :create) do
    self.code = next_seq unless attribute_present? :code
  end



  def user_names
  	users.map { |s| s.name }.sort.join(", ")
  end

  private
  def next_seq
  	result = ChecklistReport.connection.execute("SELECT nextval('checklist_reports_code_seq')")
  	result[0]['nextval']
  end


end
