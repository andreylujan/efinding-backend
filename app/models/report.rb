# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: reports
#
#  id                     :uuid             not null, primary key
#  report_type_id         :integer          not null
#  dynamic_attributes     :json             not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  creator_id             :integer          not null
#  limit_date             :datetime
#  finished               :boolean
#  assigned_user_id       :integer
#  pdf                    :text
#  pdf_uploaded           :boolean          default(FALSE), not null
#  started_at             :datetime
#  finished_at            :datetime
#  deleted_at             :datetime
#  inspection_id          :integer
#  html                   :text
#  position               :integer
#  initial_location_id    :integer
#  final_location_id      :integer
#  state                  :integer          default("unchecked"), not null
#  resolved_at            :datetime
#  resolver_id            :integer
#  resolution_comment     :text
#  initial_location_image :text
#  final_location_image   :text
#

class Report < ApplicationRecord

  before_validation :check_report_type
  # before_validation :generate_id
  acts_as_paranoid
  attr_accessor :ignore_pdf
  belongs_to :report_type
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  belongs_to :assigned_user, class_name: :User, foreign_key: :assigned_user_id
  belongs_to :resolver, class_name: :User, foreign_key: :resolver_id
  audited

  enum state: [ :unchecked, :resolved, :pending ]

  mount_uploader :pdf, PdfUploader
  mount_uploader :html, HtmlUploader
  mount_uploader :initial_location_image, ImageUploader
  mount_uploader :final_location_image, ImageUploader

  has_many :images, dependent: :destroy
  before_save :cache_data

  validates :report_type_id, presence: true
  validates :report_type, presence: true

  belongs_to :initial_location, class_name: :Location
  belongs_to :final_location, class_name: :Location

  accepts_nested_attributes_for :initial_location
  accepts_nested_attributes_for :final_location

  validates :initial_location, presence: true

  belongs_to :inspection
  acts_as_list scope: :inspection

  after_commit :generate_pdf
  after_commit :send_task_job, on: [ :create ]

  validate :limit_date_cannot_be_in_the_past, on: :create
  before_save :default_values
  before_save :check_limit_date
  after_commit :update_inspection, on: [ :create, :update ]

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

  def self.non_audited_columns
    super + [ "html", "pdf", "pdf_uploaded", "initial_location_image", "final_location_image" ]
  end

  def check_limit_date
    if limit_date.nil? and dynamic_attributes.dig('19', 'iso_string').present?
      date = DateTime.parse(dynamic_attributes.dig('19', 'iso_string'))
      .in_time_zone("Chile/Continental")
      self.limit_date = date.end_of_day
    end
  end

  def update_inspection
    if inspection.present?
      field_chief_id = dynamic_attributes.dig('16', 'id')
      needs_save = false
      if field_chief_id.present? and inspection.field_chief.nil?
        inspection.field_chief_id = field_chief_id
        needs_save = true
      end
      expert_id = dynamic_attributes.dig('17', 'id')
      if expert_id.present? and inspection.expert.nil?
        inspection.expert_id = expert_id
        needs_save = true
      end
      inspection.save!
      inspection.check_state
    end
  end

  def images_attributes=(val)
    val.each do |attrs|
      if not Image.find_by_id(attrs[:id])
        self.images << Image.new(attrs)
      end
    end
  end

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
    true
  end

  
  def send_task_job
    if self.assigned_user.present?
      SendTaskJob.set(wait: 1.second).perform_later(self.id.to_s)
    end
  end
  
  def location_attributes(location)
    {
      longitude: location.lonlat.x,
      latitude: location.lonlat.y,
      address: location.address,
      commune: location.commune,
      region: location.region,
      reference: location.reference
    }
  end

  def initial_location_attributes
    if initial_location.present?      
      location_attributes(initial_location)      
    end
  end

  def final_location_attributes
    if final_location.present?      
      location_attributes(final_location)      
    end
  end

  def generate_pdf
    if not @ignore_pdf and self.finished? and not self.pdf_uploaded?
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
