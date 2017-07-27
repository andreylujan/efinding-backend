# -*- encoding : utf-8 -*-
class Api::V1::ReportResource < ApplicationResource

  attributes :dynamic_attributes, :created_at, :limit_date,
    :finished, :pdf, :pdf_uploaded,
    :initial_location_attributes,
    :final_location_attributes,
    :started_at,
    :finished_at,
    :images_attributes, :synced, :is_draft,
    :state_name,
    :formatted_finished_at,
    :formatted_created_at,
    :formatted_limit_date,
    :formatted_resolved_at,
    :html,
    :state,
    :resolved_at,
    :resolution_comment

  add_foreign_keys :inspection_id, :creator_id, :assigned_user_id, :report_type_id

  has_one :report_type
  has_many :images
  has_one :assigned_user
  has_one :creator
  has_one :inspection
  has_one :resolver

  key_type :uuid


  filters :pdf_uploaded,
    :report_type_id, :state_name, :creator_id, :assigned_user_id

  filter :period, apply: ->(records, value, _options) {
    if not value.empty?
      date_str = value[0].split("/")
      year = date_str[1].to_i
      month = date_str[0].to_i
      rate_period = Date.new(year, month)
      records.where("reports.created_at >= ? AND reports.created_at <= ?", rate_period - 3.months, rate_period.end_of_month - 1.month)
    else
      records
    end
  }

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

  filter :inspection, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? Hash and value[0]["construction_id"].present?
        records.joins(:inspection)
          .where(inspections: { construction_id: value[0]["construction_id"] })
      else
        records
      end
    else
      records
    end
  }




  filter :state_name, apply: ->(records, value, _options) {
    records
  }

  filter :construction_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.joins(:inspection)
          .where(inspections: { construction_id: value[0] })
    else
      records
    end
  }

  filter :company_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.joins(inspection: :construction)
          .where(constructions: { company_id: value[0] })
    else
      records
    end
  }

  filter :station_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("dynamic_attributes->>'station_id' = ?", value[0])
    else
      records
    end
  }

  filter :report_type, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? Hash and value[0]["id"].present?
        records = records.where(report_type_id: value[0]["id"])
      end
    end
    records
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

  filter :formatted_resolved_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(reports.resolved_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
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


  filter :"initial_location_attributes", apply: ->(records, value, _options) {
    if not value.empty?
      records = records.includes(:initial_location)
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

  def html
    @model.html.url
  end

  before_save do
    if @model.state_changed?
      if @model.state_change[1] == "resolved" || @model.state_change[1] == "pending"
        @model.resolver = context[:current_user]
      end
      @model.pdf_uploaded = false
    end
    @model.creator_id = context[:current_user].id if @model.new_record?
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    records = Report.none
    if context[:inspection_id]
      records = Inspection.find(context[:inspection_id]).reports
    elsif context[:report_type_id]
      records = ReportType.find(context[:report_type_id]).reports
    else
      records = Report.joins(creator: { role: :organization }).where(organizations: { id: current_user.organization.id })
    end
    if options.has_key? :order
      if options[:order]
        records = records.order(options[:order])
      end
    else
      records = records.order("reports.created_at DESC")
    end

    if current_user.organization_id == 4
      if current_user.role.name == "Transportista"
        records = records.where("reports.state = 'awaiting_delivery' OR " +
          "reports.state = 'delivering' OR reports.state = 'delivered'")
      end
    end
    records.where("reports.scheduled_at IS NULL OR reports.scheduled_at <= ?", DateTime.now)

  end



  def fetchable_fields
    super - [ :initial_location_attributes, :final_location_attributes, :images_attributes,
              :report_type_id ]
  end
end
