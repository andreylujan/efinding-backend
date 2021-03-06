# -*- encoding : utf-8 -*-
class Api::V1::InspectionResource < ApplicationResource

  has_one :creator
  has_one :construction
  has_many :users
  has_one :initial_signer
  has_one :final_signer
  has_one :company
  has_one :field_chief
  has_one :expe

  attributes :created_at, :resolved_at,
    :state,
    :pdf, :pdf_uploaded,
    :formatted_created_at,
    :formatted_resolved_at,
    :formatted_final_signed_at,
    :num_pending_reports,
    :num_reports,
    :num_expired_reports,
    :state_name,
    :cached_data,
    :field_chief_name


  add_foreign_keys :construction_id

  def pdf
    @model.pdf.url
  end

  filter :num_pending_reports, apply: ->(records, value, _options) {
    if not value.empty?
      records = records
      .having("count(CASE WHEN reports.state = 'unchecked' THEN 1 END) = ?", value[0])
    else
      records
    end
  }

  filter :num_expired_reports, apply: ->(records, value, _options) {
    if not value.empty?
      records = records
      .having("count(CASE WHEN reports.state = 'unchecked' AND reports.limit_date <= '#{DateTime.now.to_s}' THEN 1 END) = ?", value[0])
    else
      records
    end
  }

  filter :num_reports, apply: ->(records, value, _options) {
    if not value.empty?
      records = records.having('count(reports.id) = ?', value[0])
    else
      records
    end
  }

  filter :state_name, apply: ->(records, value, _options) {
    if not value.empty?
      if "resuelto".include? value[0].strip.downcase
        records = records.where("inspections.state = 'final_signature_pending' OR inspections.state = 'finished'")
      elsif "pendiente".include? value[0].strip.downcase
        records = records.where.not("inspections.state = 'final_signature_pending' OR inspections.state = 'finished'")
      else
        records = records.none
      end
    else
      records
    end


    records
  }

  filter :expert, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? ActionController::Parameters and value[0]["full_name"].present?
        records.joins("LEFT OUTER JOIN users as experts ON experts.id = inspections.expert_id")
        .where("experts.first_name || ' ' || experts.last_name ilike '%" + value[0]["full_name"] + "%'")
      else
        records
      end
    else
      records
    end
  }

  filter :field_chief_name, apply: ->(records, value, _options) {
    if not value.empty?
      records.joins(:construction)
      .joins("LEFT OUTER JOIN construction_personnel ON constructions.id = construction_personnel.construction_id")
      .joins("LEFT OUTER JOIN personnel on personnel.id = construction_personnel.personnel_id")
      .where("construction_personnel.personnel_type_id = 1")
      .where("personnel.name ilike '%" + value[0] + "%'")
    else
      records
    end
  }


  filter :field_chief, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? ActionController::Parameters and value[0]["full_name"].present?
        byebug
        records.joins("LEFT OUTER JOIN users as field_chiefs ON field_chiefs.id = inspections.expert_id")
        .where("field_chiefs.first_name || ' ' || field_chiefs.last_name ilike '%" + value[0]["full_name"] + "%'")
      else
        records
      end
    else
      records
    end
  }


  filter :start_date, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("inspections.created_at >= ?", value[0])
    else
      records
    end
  }

  filter :end_date, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("inspections.created_at <= ?", value[0])
    else
      records
    end
  }

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
        if value[:administrator].present? and value[:administrator].is_a? ActionController::Parameters
          if value[:administrator][:full_name].present?
            records = records
            .joins(:construction)
            .joins("INNER JOIN users as administrators ON administrators.id = constructions.administrator_id")
            .where("administrators.first_name || ' ' || administrators.last_name ilike '%" + value[:administrator][:full_name] + "%'")
          end
        end
      end
    end
    records
  }


  filter :formatted_created_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(inspections.created_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :formatted_resolved_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(inspections.resolved_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :formatted_final_signed_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(inspections.final_signed_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }



  filter :creator, apply: ->(records, value, _options) {
    if not value.empty? and value[0].is_a? ActionController::Parameters
      if value[0]["full_name"].present?
        records = records.joins("INNER JOIN users as creators ON creators.id = inspections.creator_id")
        .where("creators.first_name || ' ' || creators.last_name ilike '%" + value[0]["full_name"] + "%'")
      end
      if value[0][:id].present?
        records = records.where(creator_id: value[0][:id])
      end
    end
    records
  }

  filter :created_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(inspections.created_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :resolved_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(inspections.resolved_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  def num_reports
    if @model.respond_to? :num_reports
      @model.num_reports
    else
      0
    end
  end

  def num_expired_reports
    if @model.respond_to? :num_expired_reports
      @model.num_expired_reports
    else
      0
    end
  end

  def num_pending_reports
    if @model.respond_to? :num_pending_reports
      @model.num_pending_reports
    else
      0
    end
  end

  def self.records(options = {})
    if options[:context] and current_user = options[:context][:current_user]
      inspections = Inspection
      .joins("LEFT OUTER JOIN reports ON reports.inspection_id = inspections.id")
      .joins(creator: :role)
      .where(roles: { organization_id: current_user.organization_id })
      .select("inspections.*, count(reports.id) as num_reports, count(case when reports.state = 'unchecked' THEN 1 END) as num_pending_reports, count(case when reports.state = 'unchecked' AND reports.limit_date <= '" +
              DateTime.now.to_s + "' THEN 1 END) as num_expired_reports")
      .group("inspections.id")

      if current_user.role_id == 2
        inspections = inspections.joins(:construction)
        .where(constructions: { supervisor_id: current_user.id })
      elsif current_user.role_id == 3
        inspections = inspections.joins(:construction)
        .where(constructions: { expert_id: current_user.id })
        .where.not(state: "reports_pending")
        .where.not(state: "first_signature_pending")
      elsif current_user.role_id == 4
        inspections = inspections.joins(:construction)
        .where(constructions: { administrator_id: current_user.id })
      end
      inspections.order("inspections.created_at DESC")
    else
      Inspection.where("1 = 0")
    end
  end

  def self.count_records(records)
    counts = records.count(:all)
    if counts.is_a? Hash
      counts.length
    else
      counts
    end
  end

  before_save do
    @model.creator_id = context[:current_user].id if @model.new_record?

    if @model.state_changed?
      if @model.state_change[1] == "first_signature_done"
        @model.initial_signer = context[:current_user]
      end
      if @model.state_change[1] == "finished"
        @model.final_signer = context[:current_user]
      end
    end
  end
end
