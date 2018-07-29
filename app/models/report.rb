# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: reports
#
#  id                  :uuid             not null, primary key
#  dynamic_attributes  :jsonb            not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :integer          not null
#  limit_date          :datetime
#  assigned_user_id    :integer
#  pdf                 :text
#  pdf_uploaded        :boolean          default(FALSE), not null
#  deleted_at          :datetime
#  inspection_id       :integer
#  initial_location_id :integer
#  final_location_id   :integer
#  state_id            :integer          not null
#  sequential_id       :integer          not null
#  organization_id     :integer          not null
#  started_at          :datetime
#  finished_at         :datetime
#  is_assigned         :boolean          default(FALSE), not null
#

class Report < ApplicationRecord


  acts_as_paranoid
  attr_accessor :ignore_pdf
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  belongs_to :assigned_user, class_name: :User, foreign_key: :assigned_user_id
  belongs_to :resolver, class_name: :User, foreign_key: :resolver_id
  belongs_to :state

  delegate :report_type, to: :state, allow_nil: false

  validates :state, presence: true

  attr_accessor :ignore_state_changes

  mount_uploader :pdf, PdfUploader

  has_many :images, dependent: :destroy
  

  belongs_to :initial_location, class_name: :Location
  belongs_to :final_location, class_name: :Location

  has_many :ActivityTemp


  accepts_nested_attributes_for :initial_location
  accepts_nested_attributes_for :final_location

  # validates :initial_location, presence: true

  belongs_to :inspection

  before_save :set_organization_id

  before_validation :check_state
  before_validation :generate_id
  before_validation :check_assigned_user, on: [ :create ]

  before_save :check_state_changed, on: [ :update ]
  before_save :check_dynamic_changes, on: [ :update ]
  before_save :check_assignment_changes, on: [ :update ]
  before_save :default_values
  before_save :check_limit_date
  after_save :change_state, on: [ :update ]
  after_commit :generate_pdf_instances, on: [ :create, :update ]

  after_commit :generate_pdf, on: [ :create, :update ]
  after_commit :send_email_pausa, on: [:update]
  after_commit :send_task_job_create, on: [ :create ]
  after_commit :send_task_job_update, on: [ :update ]

  validate :limit_date_cannot_be_in_the_past, on: :create
  validates :assigned_user, presence: true

  # validate :valid_state_transition, on: [ :update ]
  has_many :pdfs, dependent: :destroy
  acts_as_sequenced scope: :organization_id
  belongs_to :organization
  before_create :assign_user
  before_save :set_default_attributes, on: [ :create ]

  acts_as_xlsx columns: [
    :inspection_id,
    :id,
    :sequential_id,
    :state,
    :created_at,
    :limit_date,
    :creator_name,
    :initial_location_image,
    :final_location_image,
    :default_pdf,
    :resolved_at,
    :resolver_name,
    :report_fields,
    :delivery_code,
    :loto_number,
    :week_code
  ]

  def name
    self.id.to_s
  end

  def check_assigned_user
    if self.assigned_user.nil?
      self.assigned_user = self.creator
    else
      self.is_assigned = true
    end
  end

  def check_assignment_changes
    if changes["assigned_user_id"].present?
      if assigned_user_id.present?
        Rails.logger.info "User id : #{assigned_user_id}"
        self.is_assigned = true
        self.send_task_job_update
      end
    end
  end

  def dynamic_attributes=(val)
    if val.present?
      if val.is_a? String
        val = JSON.parse(val)
      end
    end
    super(val)
  end

  def check_dynamic_changes
    if changes["dynamic_attributes"].present?
      new_attrs = changes["dynamic_attributes"][1]
      old_attrs = changes["dynamic_attributes"][0]
      new_attrs.each do |data_part_id, data_part_value|
        if data_part_id == "75"
          Rails.logger.info "paso por aca 0 #{data_part_id}"
        end
        
        if data_part_value.is_a? Hash
          if old_attrs.has_key? data_part_id
            if data_part_id == "75"
              Rails.logger.info "paso por aca 1 #{data_part_id}"
            end
            
            if old_attrs[data_part_id] != data_part_value
              if data_part_id == "75"
                Rails.logger.info "paso por aca 2 #{data_part_id}"
              end
              update_field_data(data_part_value)
              dynamic_attributes[data_part_id] = data_part_value
            end
          else
            if data_part_id == "75"
              Rails.logger.info "paso por aca 3 #{data_part_id}"
            end
            update_field_data(data_part_value)
            dynamic_attributes[data_part_id] = data_part_value
          end
        else
          if data_part_id == "75"
            Rails.logger.info "paso por aca 4 #{data_part_id}"
            activities = ActivityTemp.where(report_id: self.id)
            objs = []
            activities.each do |t|
              x = t.activity 
              x["updated_at"] = t.updated_at.to_time.iso8601
              objs  << x
            end
            dynamic_attributes[data_part_id] = objs
          else
            data_part_value.select { |el| not el.has_key? "updated_at" }.each { |el| update_field_data(el) }
            dynamic_attributes[data_part_id] = data_part_value
          end
          
        end
        d = DataPart.find_by(id: data_part_id)
        if d.present? and d.assigns_user?
          user_id = data_part_value["id"]
          self.assigned_user_id = user_id
        end
      end
    end
  end

  def update_field_data(field_hash)
    field_hash["updated_at"] = DateTime.now.to_time.iso8601
  end

  def default_pdf
    if pdf_uploaded?
      the_pdf = pdfs.find { |pdf| pdf.pdf_template_id == report_type.default_pdf_template_id }
      if the_pdf.present?
        the_pdf.pdf_url
      else
        nil
      end
    end
  end

  def default_html
    if pdf_uploaded?
      the_pdf = pdfs.find { |pdf| pdf.pdf_template_id == report_type.default_pdf_template_id }
      if the_pdf.present?
        the_pdf.html_url
      else
        nil
      end
    end
  end

  def set_default_attributes
    self.dynamic_attributes = self.report_type.default_dynamic_attributes.merge(self.dynamic_attributes)
  end

  def finished=(val)
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

  def change_state
    unless self.ignore_state_changes
      if self.creator.organization_id == 6 and self.state_id_changed?
        ChangeStateJob.set(wait: 3.seconds, queue: ENV['REPORT_QUEUE'] || "etodo_report").perform_later(self.id.to_s)
      end
    end
  end

  def formatted_date_for(field)
    if field.present? and field.is_a? Hash and field["updated_at"].present?
      begin
        DateTime.parse(field["updated_at"])
        .in_time_zone(organization.time_zone)
        .strftime("%d/%m/%Y %R")
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
      :sequential_id,
      :state,
      :created_at,
      :limit_date,
      :creator_name,
      :initial_location_image,
      :final_location_image,
      :default_pdf,
      :resolved_at,
      :resolver_name,
      :delivery_code,
      :loto_number,
      :week_code
    ]
  end

  def self.column_translations
    {
      sequential_id: "Id reporte",
      created_at: "Fecha de creación",
      creator_name: "Nombre del creador",
      delivery_code: "Código de entrega",
      loto_number: "Nro Loto",
      week_code: "Nro Semana",
      default_pdf: "PDF reporte"
    }
  end

  def generate_pdf_instances
    if not @ignore_pdf
      report_type.pdf_templates.each do |template|
        pdf_instance = Pdf.find_or_initialize_by(pdf_template: template, report: self)
        pdf_instance.save!
      end
    end
  end

  def self.setup_xlsx(organization_id)
    data_parts = DataPart.joins(collection: :organization).where(organizations: {id: organization_id}).where.not(data_parts:{id:120})
    .order("data_parts.position ASC")
    cols = []
    column_translations.each do |key, value|
      define_method :"#{value}" do
        send key
      end
      cols << "#{value}"
    end

    data_parts.each do | data_part |
      define_method :"#{data_part.name}" do
        if self.dynamic_attributes.dig(data_part.id.to_s, 'items') != nil
          d = []
          self.dynamic_attributes.dig(data_part.id.to_s, 'items').each{|n| d.push("#{n.dig('name')}")}
          val = d.join(', ')
        else
          val = self.dynamic_attributes.dig(data_part.id.to_s, "value")
        end
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
      "#{dynamic_attributes.dig(key, "value")}"
    end.join("\n")
  end

  def check_limit_date
    if limit_date.nil? and dynamic_attributes.dig('19', 'iso_string').present?
      date = DateTime.parse(dynamic_attributes.dig('19', 'iso_string'))
      .in_time_zone("Chile/Continental")
      self.limit_date = date.end_of_day
    end
  end

  def self.to_csv(organization_id, start_date, end_date)
    attributes = %w{Id_reporte Fecha_creación Fecha_ultima_visita Usuario_Responsable
      Estado Pdf_reporte Dirección	Referencia  Comuna Tipo_construcción
      Constructora Persona_Contacto Mail_Contacto Telefono_Contacto Comentario}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: ';') do |csv|
      csv << attributes
      reports = Report.includes(creator: :role)
      .includes(:assigned_user)
      .where(roles: { organization_id: organization_id })
      .where("reports.created_at >= ? AND reports.created_at <= ?", start_date, end_date)
      reports.each do |report|
        csv <<[
          report.sequential_id,
          report.formatted_created_at,
          report.dynamic_attributes.dig('75').present? ? report.formatted_date_for(report.dynamic_attributes.dig('75').last): "",
          report.assigned_user_name,
          report.state.name,
          report.default_pdf,
          report.final_location.present? ? report.final_location.address : report.initial_location.address,
          report.final_location.present? ? report.final_location.reference : report.initial_location.reference,
          report.final_location.present? ? report.final_location.commune : report.initial_location.commune,
          report.dynamic_attributes.dig('66', 'value').present? ? report.dynamic_attributes.dig('66', 'value').gsub("\n"," ") : "",
          report.dynamic_attributes.dig('65', 'value').present? ? report.dynamic_attributes.dig('65', 'value').gsub("\n"," ") : "",
          report.dynamic_attributes.dig('68', 'value').present? ? report.dynamic_attributes.dig('68', 'value').gsub("\n"," ") : "",
          report.dynamic_attributes.dig('69', 'value').present? ? report.dynamic_attributes.dig('69', 'value').gsub("\n"," ") : "",
          report.dynamic_attributes.dig('10', 'value').present? ? report.dynamic_attributes.dig('70', 'value').gsub("\n"," ") : "",
          report.dynamic_attributes.dig('74', 'value').present? ? report.dynamic_attributes.dig('74', 'value').gsub("\n"," ") : ""
        ]
      end
    end
  end

  def images_attributes=(val)
    val = val.map do |v|
      if v["attributes"].present?
        v["attributes"].delete "uploaded"
        v["attributes"]
      else
        v.delete "uploaded"
        v
      end
    end
    val.each do |attrs|
      if not image = Image.find_by_id(attrs[:id])
        self.images << Image.new(attrs)
      else
        image.update_attributes attrs
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

  def assigned_user_name
    assigned_user.present? ? assigned_user.name : ""
  end


  def start_location_coords
  end

  def finish_location_coords
  end

  def location_delta
  end

  def formatted_created_at
    created_at.in_time_zone(organization.time_zone).strftime("%d/%m/%Y %R")
  end

  def formatted_limit_date
    limit_date.in_time_zone(organization.time_zone).strftime("%d/%m/%Y %R") if limit_date.present?
  end

  def formatted_started_at
    started_at.in_time_zone(organization.time_zone).strftime("%d/%m/%Y %R") if started_at.present?
  end

  def formatted_finished_at
    finished_at.in_time_zone(organization.time_zone).strftime("%d/%m/%Y %R") if finished_at.present?
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
    true
  end
  def send_email_pausa
    MailerJob.set(wait: 10.seconds, queue: ENV['REPORT_QUEUE'] || 'etodo_report').perform_later(self.id.to_s)
  end
  def send_email_manflas
    MailerJob.set(wait: 10.seconds, queue: ENV['REPORT_QUEUE'] || 'etodo_report').perform_later(self.id.to_s)
  end

  def send_task_job_create
    if self.assigned_user.present?
      SendTaskJob.set(wait: 1.seconds, queue: ENV['PUSH_QUEUE'] || 'etodo_push').perform_later(self.id.to_s)
    end
  end


  def send_task_job_update
    if changes["assigned_user_id"].present? and self.assigned_user.present?
      SendTaskJob.set(wait: 1.seconds, queue: ENV['PUSH_QUEUE'] || 'etodo_push').perform_later(self.id.to_s)
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
    if not @ignore_pdf
      self.pdf_uploaded = false
      regenerate_pdf(true)
    end
  end

  def regenerate_pdf(force_random = false)
    if not destroyed? and report_type.has_pdf?
      if force_random
        update_columns pdf: nil, pdf_uploaded: false
      end
      UploadPdfJob.set(wait: 1.seconds, queue: ENV['REPORT_QUEUE'] || 'etodo_report').perform_later(self.id.to_s)
    end
  end

  def delivery_code
    if self.creator.organization_id != nil and self.creator.organization_id == 12
      if self.dynamic_attributes.dig('119', 'value') != nil
        "#{self.dynamic_attributes.dig('119','value').split(' - ')[0]} - W#{self.created_at.strftime("%W").to_i}"
      else
        "No existe código de entrega"
      end
    end
  end

  def loto_number
    if self.creator.organization_id != nil and self.creator.organization_id == 12
      if self.dynamic_attributes.dig('119', 'value') != nil
        "#{self.dynamic_attributes.dig('119','value').split(' - ')[0]}"
      else
        "No número de loto"
      end
    end
  end

  def week_code
    if self.creator.organization_id != nil and self.creator.organization_id == 12
      self.created_at.strftime("%W").to_i
    end
  end

  def delivery_type
    if self.creator.organization_id != nil and self.creator.organization_id == 12
      if self.dynamic_attributes.dig('117', 'items') != nil
        d = []
        self.dynamic_attributes.dig('117', 'items').each{|n| d.push("#{n.dig('name')}")}
        d.join(', ')
      end
    end
  end

  private
  def set_organization_id
    self.organization_id = creator.organization_id
  end

  def limit_date_cannot_be_in_the_past
    if limit_date.present? && limit_date < DateTime.now
      errors.add(:limit_date, "No puede estar en el pasado")
    end
  end
end
