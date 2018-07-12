# -*- encoding : utf-8 -*-
class Api::V1::ReportResource < ApplicationResource

  attributes :dynamic_attributes,
    :created_at,
    :updated_at,
    :limit_date,
    :finished,
    :pdf,
    :pdf_uploaded,
    :initial_location_attributes,
    :final_location_attributes,
    :images_attributes,
    :synced,
    :is_draft,
    :formatted_created_at,
    :formatted_limit_date,
    :sequential_id,
    :started_at,
    :finished_at,
    :formatted_started_at,
    :formatted_finished_at,
    :delivery_code,
    :loto_number,
    :week_code,
    :delivery_type

  add_foreign_keys :inspection_id, :creator_id, :assigned_user_id, :state_id

  has_many :images
  has_one :assigned_user
  has_one :creator
  has_one :inspection
  has_one :state
  has_one :organization

  has_many :pdfs

  key_type :uuid


  filters :pdf_uploaded,
    :state_id, :creator_id, :assigned_user_id

  filter :creator_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("reports.creator_id = ?", value[0])
    else
      records
    end
  }
  filter :sequential_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("reports.sequential_id = ?", value[0])
    else
      records
    end
  }
  filter :assigned_user_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("reports.assigned_user_id = ?", value[0])
    else
      records
    end
  }

  filter :creator, apply: ->(records, value, _options) {
    Rails.logger.info "creator : #{value.first}"
    if not value.empty?
      if (value[0].is_a? Hash or value[0].is_a? ActionController::Parameters) and value[0]["full_name"].present?
        records.includes(:assigned_user, :creator).where("users.first_name || ' ' || users.last_name ilike '%" + value[0]["full_name"] + "%'")
        .where.not(creator_id: nil).references(:users)
      else
        records
      end
    else
      records
    end
  }

  filter :state, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? Hash or value[0].is_a? ActionController::Parameters
        if value[0]["id"].present?
          records = records.joins(:state).where(state_id: value[0]["id"])
        end
        if value[0]["name"].present?
          records = records.joins(:state).where("states.name ilike ?", "%#{value[0]['name']}%")
        end
      end
    end
    records
  }

  filter :assigned_user, apply: ->(records, value, _options) {
    if not value.empty?
      if (value[0].is_a? Hash or value[0].is_a? ActionController::Parameters) and value[0]["full_name"].present?
        records.includes(:assigned_user, :creator).where("users.first_name || ' ' || users.last_name ilike '%" + value[0]["full_name"] + "%'")
        .where.not(assigned_user_id: nil).references(:users)
      else
        records
      end
    else
      records
    end
  }

  filter :pdfs, apply: ->(records, value, _options) {
    records
  }

  filter :created_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.created_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :limit_date, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.limit_date, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :formatted_created_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.created_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :formatted_limit_date, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.limit_date, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :formatted_started_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.started_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :formatted_finished_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.finished_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :assigned_user_name, apply: ->(records, value, _options) {
    if not value.empty?
      records.joins(:assigned_user).where("users.first_name || ' ' || users.last_name ILIKE ?", "%#{value.first}%")
      .references(:assigned_user)
    else
      records
    end
  }

  filter :delivery_code, apply: ->(records, value, _options){
    key = '119'
    subkey = 'value'
    if not value.empty?
      records = records.where("concat(split_part(reports.dynamic_attributes -> '#{key}' ->> '#{subkey}','-',1),' - W',date_part('week',reports.created_at)) ILIKE ?", "%#{value.first}%")
    else
      records
    end
  }
  filter :loto_number, apply: ->(records, value, _options){
    key = '119'
    subkey = 'value'
    if not value.empty?
      records.where("split_part(reports.dynamic_attributes -> '#{key}' ->> '#{subkey}','-',1) ILIKE ?", "%#{value.first}%")
    else
      records
    end
  }

  filter :week_code, apply: ->(records, value, _options){
    if not value.empty?
      records.where("date_part('week',reports.created_at) = ?", "#{value.first}")
    else
      records
    end
  }

  filter :delivery_type, apply: ->(records, value, _options){
    key = '117'
    subkey = 'items'
    if not value.empty?
      records.where("reports.dynamic_attributes -> '#{key}' ->> '#{subkey}' ILIKE ?", "%#{value.first}%")
    else
      records
    end
  }

  filter :"initial_location_attributes", apply: ->(records, value, _options) {
    if not value.empty?
      records = records.includes(:initial_location)
    end
    if (value.first.is_a? Hash or value.first.is_a? ActionController::Parameters)
      value.first.each do |key, key_value|
        if not key_value.blank?
          records = records.where("locations.#{key} ILIKE ?", "%#{key_value}%")
        end
      end
    end
    records
  }

  filter :dynamic_attributes, apply: ->(records, value, _options) {
    if not value.empty?
      applied_filter = value.first
      if applied_filter.is_a? Hash or applied_filter.is_a? ActionController::Parameters
        applied_filter.each do |key, value|
          value.each do |subkey, subvalue|
            if not subvalue.blank?
              records = records.where("dynamic_attributes -> '#{key}' ->> '#{subkey}' ILIKE ?", "%#{subvalue}%")
            end
          end
        end
      end
      records
    else
      records
    end
  }



  filter :ids, apply: ->(records, value, _options) {
    if not value.empty?
      records.where(id: value)
    else
      records
    end
  }
  filter :exclude_state, apply: ->(records, value, _options) {
    if not value.empty?
      #records.where.not(state_id: value)
      records.where.not(:state_id => value)
    else
      records
    end
  }
  filter :lost_business, apply: ->(records, value, _options) {
    if not value.empty?
      #records.where.not(state_id: value)
      records.where.not("(dynamic_attributes->'63') is null and state_id = 9")
    else
      records
    end
  }

  def custom_links(options)
    {self: nil}
  end

  def is_draft
    false
  end

  def synced
    true
  end

  def pdf
    @model.default_pdf
  end

  def finished
    true
  end

  before_save do
    current_user = context[:current_user]
    if @model.creator.nil?
      @model.creator = current_user
    end
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    records = Report.none

    if context[:inspection_id]
      records = Inspection.find(context[:inspection_id]).reports
    elsif context[:state_id]
      records = State.find(context[:state_id]).reports
    else
      records = Report.joins(creator: { role: :organization }).where(organizations: { id: current_user.organization.id })
    end
    if options.has_key? :order
      records = records.order(options[:order])
    else
      records = records.order("reports.created_at DESC")
    end

    if current_user.role_id == 14
      records = records.where("reports.assigned_user_id = ?", current_user.id)
    end
    records.includes(:initial_location)

  end



  def fetchable_fields
    super - [ :images_attributes ]
  end
end
