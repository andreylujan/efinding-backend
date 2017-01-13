# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: reports
#
#  id                 :uuid             not null, primary key
#  report_type_id     :integer          not null
#  dynamic_attributes :json             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  creator_id         :integer          not null
#  limit_date         :datetime
#  finished           :boolean
#  assigned_user_id   :integer
#  pdf                :text
#  pdf_uploaded       :boolean          default(FALSE), not null
#  start_location_id  :integer
#  marked_location_id :integer
#  finish_location_id :integer
#  started_at         :datetime
#  finished_at        :datetime
#  deleted_at         :datetime
#  end_location_id    :integer
#  inspection_id      :integer
#

class Report < ApplicationRecord

  before_validation :check_report_type
  # before_validation :generate_id
  acts_as_paranoid
  belongs_to :report_type
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  belongs_to :assigned_user, class_name: :User, foreign_key: :assigned_user_id
  mount_uploader :pdf, PdfUploader
  has_many :images, dependent: :destroy
  before_save :cache_data
  validates :report_type_id, presence: true
  validates :report_type, presence: true
  belongs_to :marked_location, class_name: :Location
  belongs_to :start_location, class_name: :Location
  belongs_to :finish_location, class_name: :Location
  belongs_to :end_location, class_name: :Location
  accepts_nested_attributes_for :marked_location
  accepts_nested_attributes_for :end_location
  accepts_nested_attributes_for :images, update_only: false
  accepts_nested_attributes_for :start_location
  accepts_nested_attributes_for :finish_location
  belongs_to :inspection
  
  after_commit :generate_pdf
  after_commit :send_task_job, on: [ :create ]

  validate :limit_date_cannot_be_in_the_past, on: :create
  before_save :default_values

  acts_as_xlsx columns: [
    :id,
    :created_at,
    :finished_at,
    :limit_date,
    :creator_email,
    :assigned_user_email,
    :start_location_coords,
    :finish_location_coords,
    :location_delta,
    :execution_time,
    :pdf_url
  ]

  def creator_email
    creator.email
  end

  def assigned_user_email
    assigned_user.present? ? assigned_user.email : creator.email
  end

  def start_location_coords
  end

  def finish_location_coords
  end

  def location_delta
  end

  def formatted_finished_at
    finished_at.strftime("%d/%m/%Y %R") if finished_at.present?
  end

  def formatted_created_at
    created_at.strftime("%d/%m/%Y %R")
  end

  def formatted_limit_date
    limit_date.strftime("%d/%m/%Y %R") if limit_date.present?
  end

  def execution_time
    if finished_at.present? and started_at.present?
      ((finished_at - started_at)/1.minute).round(2)
    end
  end

  def generate_id
    if self.id.nil?
      self.id = SecureRandom.uuid
    end
  end

  def state_name
    if self.finished?
      "Ejecutado"
    else
      "Pendiente"
    end
  end

  def month_criteria
    self.created_at.beginning_of_month
  end

  def assign_default_values
    if self.finished.nil?
      self.finished = false
    end
  end

  def user_email=(val)
    self.assigned_user = User.find_by_email!(val)
  end

  def serial_number=(val)
    self.equipment = Equipment.find_by_serial_number!(val)
  end

  def check_report_type
    if self.report_type.nil? and self.creator.present?
      self.report_type = self.creator.organization.report_types.first
    end
  end
  
  def assigned_user_name
    if assigned_user.present?
      assigned_user.name
    else
      creator.name
    end
  end
  
  def default_values
    if self.pdf_uploaded.nil?
      self.pdf_uploaded = false
    end
    if self.finished.nil?
      self.finished = false
    end
    if self.equipment.present?
      if self.dynamic_attributes.nil?
        self.dynamic_attributes = {}
      end
      self.dynamic_attributes["class"] = self.equipment.equipment_class
      self.dynamic_attributes["serial_number"] = self.equipment.serial_number
      self.dynamic_attributes["3"] = { text: self.equipment.equipment_class }
      self.dynamic_attributes["5"] = { text: self.equipment.serial_number }
    end
    true
  end

  
  def send_task_job
    if self.assigned_user.present?
      SendTaskJob.set(wait: 1.second).perform_later(self.id.to_s)
    end
  end
  
  def marked_location_attributes
    if marked_location.present?
      {
        longitude: marked_location.lonlat.x,
        latitude: marked_location.lonlat.y,
        address: marked_location.address,
        commune: marked_location.commune,
        region: marked_location.region,
        reference: marked_location.reference
      }
    end
  end


  def generate_pdf
    if self.finished? and not self.pdf_uploaded?
      regenerate_pdf
    end
  end

  def receptor
    if self.dynamic_attributes["14"].present? and self.dynamic_attributes["14"]["text"] != ""
      self.dynamic_attributes["14"]["text"]
    else
      "No hay datos del receptor"
    end
  end

  def checklist_items
    items = []
    self.dynamic_attributes.each do |key, value|
      item = ChecklistItem.find_by_id(key)
      if item.present?
        info = {
          value: value["value"],
          name: item.name,
          observation: item.config["observation"],
          position: item.position
        }
        items << info
      end
    end
    items.sort! { |a,b| b[:position] <=> a[:position] }
  end

  def regenerate_pdf(force_random = false)
    if force_random
      update_columns pdf: nil, pdf_uploaded: false
    end
    UploadPdfJob.set(queue: ENV['REPORT_QUEUE'] || 'echeckit_report').perform_later(self.id.to_s)
  end

  def cache_data
    if self.dynamic_attributes.nil?
      self.dynamic_attributes = {}
    end
  end

  private
  def limit_date_cannot_be_in_the_past
    if limit_date.present? && limit_date < DateTime.now
      errors.add(:limit_date, "No puede estar en el pasado")
    end
  end


end
