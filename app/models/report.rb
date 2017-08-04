# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: reports
#
#  id                     :uuid             not null, primary key
#  dynamic_attributes     :jsonb            not null
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
#  resolved_at            :datetime
#  resolver_id            :integer
#  resolution_comment     :text
#  initial_location_image :text
#  final_location_image   :text
#  scheduled_at           :datetime
#  state_id               :integer          not null
#

class Report < ApplicationRecord

  # state_machine :state do
  # end

  # # Replace this with an external source (like a db)
  # def transitions
  #   trans = StateTransition.joins(:previous_state)
  #     .where(states: { report_type_id: self.report_type_id })
  #     .map do |transition|
  #       trans_hash = {}
  #       trans_hash[transition.previous_state.name] =
  #         transition.next_state.name
  #       trans_hash[:on] = transition.action
  #       trans_hash
  #     end
  #   trans
  # end

  # # Create a state machine for this vehicle instance dynamically based on the
  # # transitions defined from the source above
  # def machine
  #   if report_type.present?
  #     report = self
  #     # @machine ||= Machine.new(report, initial: :parked, action: :save) do
  #     Machine.new(report, initial: report.state || report_type.initial_state.name, action: :save) do
  #       report.transitions.each {|attrs| transition(attrs)}
  #     end
  #   end
  # end

  # # Generic class for building machines
  # class Machine
  #   def self.new(object, *args, &block)
  #     machine_class = Class.new
  #     machine = machine_class.state_machine(*args, &block)
  #     attribute = machine.attribute
  #     action = machine.action

  #     # Delegate attributes
  #     machine_class.class_eval do
  #       define_method(:definition) { machine }
  #       define_method(attribute) { object.send(attribute) }
  #       define_method("#{attribute}=") {|value| object.send("#{attribute}=", value) }
  #       define_method(action) { object.send(action) } if action
  #     end

  #     machine_class.new
  #   end
  # end

  # def save
  # Save the state change...
  #  true
  # end

  before_validation :check_state
  before_validation :generate_id
  acts_as_paranoid
  attr_accessor :ignore_pdf
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  belongs_to :assigned_user, class_name: :User, foreign_key: :assigned_user_id
  belongs_to :resolver, class_name: :User, foreign_key: :resolver_id
  belongs_to :state

  delegate :report_type, to: :state, allow_nil: false

  validates :state, presence: true

  # enum state: [ :unchecked, :resolved, :pending ]
  attr_accessor :ignore_state_changes

  mount_uploader :pdf, PdfUploader
  mount_uploader :html, HtmlUploader
  mount_uploader :initial_location_image, ImageUploader
  mount_uploader :final_location_image, ImageUploader

  has_many :images, dependent: :destroy
  

  belongs_to :initial_location, class_name: :Location
  belongs_to :final_location, class_name: :Location

  accepts_nested_attributes_for :initial_location
  accepts_nested_attributes_for :final_location

  # validates :initial_location, presence: true

  belongs_to :inspection
  acts_as_list scope: :inspection

  before_save :cache_data
  before_save :check_assigned_user
  before_save :check_state_changed, on: [ :update ]
  before_save :check_dynamic_changes, on: [ :update ]
  before_save :default_values
  before_save :check_limit_date

  after_commit :generate_pdf # , on: [ :create ]
  after_commit :send_task_job_create, on: [ :create ]
  after_commit :send_task_job_update, on: [ :update ]
  
  validate :limit_date_cannot_be_in_the_past, on: :create
  validate :valid_state_transition, on: [ :update ]
  
  before_create :assign_user
  before_create :assign_labels
  after_commit :update_inspection, on: [ :create, :update ]

  acts_as_xlsx columns: [
    :inspection_id,
    :id,
    :state,
    :created_at,
    :limit_date,
    :creator_name,
    :initial_location_image,
    :final_location_image,
    :pdf_url,
    :resolved_at,
    :resolver_name,
    :resolution_comment,
    :report_fields
  ]

  def check_assigned_user
    if self.assigned_user.nil?
      self.assigned_user = self.creator
    end
  end

  def check_dynamic_changes
    if changes["dynamic_attributes"].present?
      new_attrs = changes["dynamic_attributes"][1]
      old_attrs = changes["dynamic_attributes"][0]
      new_attrs.each do |data_part_id, data_part_value|
        if data_part_value.is_a? Hash
          if old_attrs.has_key? data_part_id
            if old_attrs[data_part_id] != data_part_value
              update_field_data(data_part_value)
              dynamic_attributes[data_part_id] = data_part_value
            end
          else
            update_field_data(data_part_value)
            dynamic_attributes[data_part_id] = data_part_value
          end
        else
          data_part_value.select { |el| not el.has_key? "updated_at" }.each { |el| update_field_data(el) }
          dynamic_attributes[data_part_id] = data_part_value
        end
      end
    end
  end

  def update_field_data(field_hash)
    field_hash["updated_at"] = DateTime.now.to_time.iso8601
  end

  def assign_labels
    self.dynamic_attributes["55"] = {
      value: "6%"
    }
  end

  def check_state_changed
    if self.state_id_changed?
      assign_attributes pdf: nil, pdf_uploaded: false
    end
  end

  def valid_state_transition
    if state.present? and changes[:state_id].present?
      previous_state = State.find(changes[:state_id][0])
      new_state = previous_state.next_states.find_by_id(changes[:state_id][1])
      if new_state.nil?
        errors.add(:state, "Transición inválida")
      end
    end
  end

  def assign_user
    if creator.present? and creator.organization_id == 3
      area_id = dynamic_attributes.dig("43", "id")
      if area_id.present?
        item = CollectionItem.find(area_id)
        self.assigned_user = item.resource_owner
        if self.assigned_user.present?
          self.dynamic_attributes["assigned_user"] = {
            name: self.assigned_user.name,
            email: self.assigned_user.email,
            id: self.assigned_user.id
          }
        end
      end
    end
  end

  def formatted_date_for(field)
    if field.present? and field.is_a? Hash and field["updated_at"].present?
      begin
        DateTime.parse(field["updated_at"]).strftime("%d/%m/%Y %R")
      rescue => exception
        "Fecha inválida"
      end
    else
      "Sin fecha"
    end
  end

  def resolver_name
    if resolver.present?
      resolver.name
    end
  end

  def self.standard_columns
    [
      :inspection_id,
      :id,
      :state,
      :created_at,
      :limit_date,
      :creator_name,
      :initial_location_image,
      :final_location_image,
      :pdf_url,
      :resolved_at,
      :resolver_name,
      :resolution_comment
    ]
  end

  def self.column_translations
    {
      inspection_id: "Id inspección",
      id: "Id reporte",
      state: "Estado",
      created_at: "Fecha de creación",
      limit_date: "Fecha límite",
      creator_name: "Nombre del creador",
      initial_location_image: "Ubicación inicial",
      final_location_image: "Ubicación de resolución",
      pdf_url: "PDF hallazgo",
      resolved_at: "Fecha de resolución",
      resolution_comment: "Comentario de resolución"
    }
  end

  def self.setup_xlsx(organization_id)
    data_parts = DataPart.joins(section: :report_type).where(report_types: { organization_id: organization_id})
    .order("sections.position ASC, data_parts.position ASC")
    cols = []
    column_translations.each do |key, value|
      define_method :"#{value}" do
        send key
      end
      cols << "#{value}"
    end
    data_parts.each do | data_part |
      define_method :"#{data_part.name}" do
        val = dynamic_attributes.dig(data_part.id.to_s, "text")
        if (val.nil? or val == "") and inspection.present?
          cached_id = data_part.config.dig("depends", "cached_id")
          inspection.cached_data[cached_id]
        else
          val
        end
      end
      cols << data_part.name
    end
    Report.acts_as_xlsx columns: cols
  end

  def report_fields
    dynamic_attributes.map do |key, val|
      data_part = DataPart.find(key)
      "#{data_part.name} - #{val['text']}"
    end.join("\n")
  end

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


  def station
    station_id = dynamic_attributes.dig("station_id")
    if station_id.present?
      Mongoid.raise_not_found_error = false
      @station ||= Manflas::Station.find(station_id)
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
    val = val.map do |v|
      if v["attributes"].present?
        state_id = v["attributes"]["state"]["id"]
        v["attributes"].delete("state")
        v["attributes"]
      else
        v
      end
    end
    val.each do |attrs|
      if not Image.find_by_id(attrs[:id])
        self.images << Image.new(attrs)
      end
    end
  end

  def creator_email
    creator.email
  end

  def creator_name
    creator.name
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

  def formatted_resolved_at
    resolved_at.strftime("%d/%m/%Y %R") if resolved_at.present?
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

  def month_criteria
    self.created_at.beginning_of_month
  end

  def assign_default_values
    if self.finished.nil?
      self.finished = false
    end
    if self.assigned_user.nil?
      self.assigned_user = self.creator
    end
  end

  def user_email=(val)
    self.assigned_user = User.find_by_email!(val)
  end


  def check_state
    if self.state.nil? and self.creator.present?
      org = self.creator.organization
      if org.default_report_type.present?
        self.state = org.default_report_type.initial_state
      end
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

  def send_task_job_create
    if self.assigned_user.present?
      SendTaskJob.set(wait: 1.second, queue: ENV['PUSH_QUEUE'] || 'efinding_push').perform_later(self.id.to_s)
    end
  end

  def send_task_job_update
    if changes["assigned_user_id"].present? and self.assigned_user.present?
      SendTaskJob.set(wait: 1.second, queue: ENV['PUSH_QUEUE'] || 'efinding_push').perform_later(self.id.to_s)
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
      regenerate_pdf(true)
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
    if not destroyed? and report_type.has_pdf?
      if force_random
        update_columns pdf: nil, pdf_uploaded: false
      end
      UploadPdfJob.set(queue: ENV['REPORT_QUEUE'] || 'echeckit_report').perform_later(self.id.to_s)
    end
  end

  def station_id_criteria
    dynamic_attributes["station_id"]
  end

  def cache_data
    if self.dynamic_attributes.nil?
      self.dynamic_attributes = {}
    end
    if self.dynamic_attributes["station_id"].present?
      Mongoid.raise_not_found_error = false
      station = Manflas::Station.find(dynamic_attributes["station_id"])
      if station.present?
        dynamic_attributes["station"] = {
          text: station.name
        }
        dynamic_attributes["sector"] = {
          text: station.sector
        }
      end
    end
  end

  def get_message
    if self.creator.organization_id == 4
      sections = dynamic_attributes.dig("47", "sections")
      if sections.present?
        suggestions = []
        sections.each do |section|
          section["items"].each do |item|
            if item["value"] == 0 and item["comment"].present?
              suggestions << (item["name"].gsub("\n", " ") + ": " + item["comment"])
            end
          end
        end
        return suggestions.join("\n\n")
      end
    end
  end

  private
  def limit_date_cannot_be_in_the_past
    if limit_date.present? && limit_date < DateTime.now
      errors.add(:limit_date, "No puede estar en el pasado")
    end
  end
  


       end
