# -*- encoding : utf-8 -*-
class Api::V1::ChecklistReportResource < ApplicationResource
  
  attributes :checklist_data, :formatted_created_at, :pdf, :pdf_uploaded,
    :code, :user_names, :location_attributes, :total_indicator, :user_ids,
    :finished, :started_at, :created_at, :html

  add_foreign_keys :construction_id, :checklist_id

  has_one :checklist
  has_many :users
  has_one :creator
  has_one :construction

  key_type :uuid
  
  def finished
    true
  end

  def code
    "#{@model.construction.code}-#{@model.code}"
  end

  def user_names
    if @model.respond_to? :user_names
      @model.user_names
    end
  end

  def pdf
    @model.pdf.url
  end

  def html
    @model.html.url
  end

  filter :code, apply: ->(records, value, _options) {
    if not value.empty?
      records = records
        .joins(:construction)
        .where("constructions.code || '-' || checklist_reports.code::text ilike '%" + value[0].to_s + "%'")
    end
    records
  }

  filter :total_indicator, apply: ->(records, value, _options) {
    if not value.empty?
      # records = records.where("'95%' ilike '%" + value[0].to_s + "%'")
      records
    end
    records
  }

  filter :user_names, apply: ->(records, value, _options) {
    # if not value.empty?
    #   names = value.join(",")
    #   records = records
    #   .having("string_agg(checklist_users.first_name || ' ' || checklist_users.last_name, ', ' ORDER BY " + 
    #     "checklist_users.first_name || ' ' || checklist_users.last_name) ILIKE '%" +
    #     names + "%'")
    # end
    records
  }

  # filter :creator, apply: ->(records, value, _options) {
  #   if not value.empty? and value[0].is_a? ActionController::Parameters
  #     if value[0]["full_name"].present?
  #       records = records.joins("INNER JOIN users as creators ON creators.id = checklist_reports.creator_id")
  #       .where("creators.first_name || ' ' || creators.last_name ilike '%" + value[0]["full_name"] + "%'")
  #     end
  #     if value[0][:id].present?
  #       records = records.where(creator_id: value[0][:id])
  #     end
  #   end
  #   records
  # }

  filter :construction, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? ActionController::Parameters
        value = value[0]
        if value[:name].present?
          records = records.joins(:construction).where("constructions.name ilike '%" + value[:name] + "%'")
        end
        if value[:id].present?
          records = records.where(construction_id: value[:id])
        end
        if value[:company].present? and value[:company].is_a? ActionController::Parameters
          if value[:company][:name].present?
            records = records.joins(construction: :company).where("companies.name ilike '%" + value[:company][:name] + "%'")
          end
          if value[:company][:id].present?
            records = records.joins(:construction).where("constructions.company_id = ?", value[:company][:id])
          end
          if value[:company][:organization].present? and value[:company][:organization].is_a? ActionController::Parameters
            if value[:company][:organization][:name].present?
              records = records.joins(construction: { company: :organization})
              .where("organizations.name ilike '%" + value[:company][:organization][:name] + "%'")
            end
          end
        end

      end
    end
    records
  }

  before_save do
    @model.creator_id = context[:current_user].id if @model.new_record?
    @model.report_type_id = 2 if @model.new_record?
  end

  filter :formatted_created_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(checklist_reports.created_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  def self.count_records(records)
    count = records.distinct.count(:all)
    if count.is_a? Hash
      count.values.sum
    else
      count
    end
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    if context[:current_user]
      checklists = ChecklistReport.joins(creator: { role: :organization })
      .joins(:construction)
      .group("checklist_reports.id")
      .where(organizations: { id: current_user.organization.id })
      
      if current_user.role_id == 2
        checklists = checklists.joins(:construction)
          .where(constructions: { supervisor_id: current_user.id })
      elsif current_user.role_id == 3
        checklists = checklists.joins(:construction)
          .where(constructions: { expert_id: current_user.id })
      elsif current_user.role_id == 4
        checklists = checklists.joins(:construction)
          .where(constructions: { administrator_id: current_user.id })
      end

    end
    checklists
  end

  def fetchable_fields
    super - [ :location_attributes, :user_ids ]
  end

end
