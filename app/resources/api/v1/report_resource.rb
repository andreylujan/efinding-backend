# -*- encoding : utf-8 -*-
class Api::V1::ReportResource < ApplicationResource
  attributes :dynamic_attributes, :creator_id, :created_at, :limit_date,
    :finished, :assigned_user_id, :pdf, :pdf_uploaded, :marked_location_attributes,
    :start_location_attributes, :finish_location_attributes, :started_at,
    :finished_at, :images_attributes, :report_type_id, :synced, :is_draft,
    :state_name, :equipment_id, :activity_type_id,
    :formatted_finished_at, :formatted_created_at, :formatted_limit_date,
    :end_location_attributes

  has_one :report_type
  has_many :images
  has_one :assigned_user
  has_one :creator
  key_type :uuid

  has_one :equipment
  has_one :activity_type

  def started_at
    @model.started_at.strftime("%d/%m/%Y %R") if @model.started_at.present?
  end

  filters :pdf_uploaded,
    :report_type_id, :state_name, :creator_id
 

  filter :creator, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? Hash and value[0]["full_name"].present?
        records.includes(:assigned_user, :creator).where("creators_reports.first_name || ' ' || creators_reports.last_name ilike '%" + value[0]["full_name"] + "%'")
          .where.not(creator_id: nil).references(:users)

      else
        records
      end
    else
      records
    end
  }

  filter :assigned_user, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? Hash and value[0]["full_name"].present?
        records.includes(:assigned_user, :creator).where("users.first_name || ' ' || users.last_name ilike '%" + value[0]["full_name"] + "%'")
        .where.not(assigned_user_id: nil).references(:users)
      else
        records
      end
    else
      records
    end
  }

  

  filter :started_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.started_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
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

  filter :finished_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.finished_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
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

  filter :formatted_finished_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.finished_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :finished, apply: ->(records, value, _options) {
    if not value.empty?
      records.where(finished: value)
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

  filter :"equipment", apply: ->(records, value, _options) {
    if not value.empty?
      records = records.includes(:equipment)
    end
    if value.first.is_a? Hash
      value.first.each do |key, key_value|
        if not key_value.blank?
          records = records.where("equipments.#{key} ILIKE ?", "%#{key_value}%")
        end
      end
    end
    records
  }

  filter :"marked_location_attributes", apply: ->(records, value, _options) {
    if not value.empty?
      records = records.includes(:marked_location)
    end
    if value.first.is_a? Hash
      value.first.each do |key, key_value|
        if not key_value.blank?
          records = records.where("locations.#{key} ILIKE ?", "%#{key_value}%")
        end
      end
    end
    records
  }

  filter :"activity_type", apply: ->(records, value, _options) {
    if not value.empty?
      records = records.joins(:activity_type)
    end
    if value.first.is_a? Hash
      value.first.each do |key, key_value|
        if not key_value.blank?
          records = records.where("activity_types.#{key} ILIKE ?", "%#{key_value}%")
        end
      end
    end
    records
  }

  filter :dynamic_attributes, apply: ->(records, value, _options) {
    if not value.empty?
      applied_filter = value.first
      if applied_filter.is_a? Hash
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

  def equipment_id
    @model.equipment_id.to_s if @model.equipment_id
  end

  def activity_type_id
    @model.activity_type_id.to_s if @model.activity_type_id
  end

  def creator_id
    @model.creator_id.to_s
  end

  def assigned_user_id
    if @model.assigned_user_id
      @model.assigned_user_id.to_s
    end
  end

  def report_type_id
    @model.report_type_id.to_s
  end

  def custom_links(options)
    {self: nil}
  end

  def is_draft
    0
  end

  def synced
    1
  end

  def pdf
    @model.pdf.url
  end

  before_save do
    @model.creator_id = context[:current_user].id if @model.new_record?
    if @model.report_type.nil? or @model.report_type.organization_id != context[:current_user].role.organization_id
      if context[:current_user].organization.default_report_type.present?
        @model.report_type = context[:current_user].organization.default_report_type
      else
        @model.report_type = context[:current_user].organization.report_types.first
      end
    end
  end

  def self.records(options = {})
    context = options[:context]
    user = context[:current_user]

    if not context[:zip] and (user.role.name != "admin" or !context[:all])
      user.viewable_reports.order("created_at DESC")
    else
      Report.joins(:report_type)
      .where(report_types: { organization_id: user.organization_id })
      .order("reports.created_at DESC")
    end
  end



  def fetchable_fields
    super - [ :start_location_attributes, :finish_location_attributes, :images_attributes,
              :report_type_id, :end_location_attributes ]
  end
end
