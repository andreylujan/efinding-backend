class Api::V1::InspectionResource < ApplicationResource

  has_one :creator
  has_one :construction
  has_many :users
  has_one :initial_signer
  has_one :final_signer
  has_one :company
  has_one :field_chief
  has_one :expert
  has_one :administrator

  attributes :created_at, :resolved_at, 
    :state,
    :pdf, :pdf_uploaded,
    :formatted_created_at,
    :formatted_resolved_at,
    :formatted_final_signed_at,
    :num_pending_reports,
    :num_reports,
    :num_expired_reports,
    :state_name


  def num_expired_reports
    @model.reports.where("limit_date <= ?", DateTime.now).count
  end

  def num_pending_reports
    @model.reports.where(state: "unchecked").count
  end

  

  add_foreign_keys :construction_id

  def pdf
    @model.pdf.url
  end

  filter :num_pending_reports, apply: ->(records, value, _options) {
    if not value.empty?
      records = records.joins("FULL OUTER JOIN reports ON reports.inspection_id = inspections.id AND reports.state = #{Report.states['unchecked']}")
      .group("inspections.id").having('count(reports.id) = ?', value[0])
    else
      records
    end
  }

  filter :num_expired_reports, apply: ->(records, value, _options) {
    if not value.empty?
      records = records
      .joins("FULL OUTER JOIN reports ON reports.inspection_id = inspections.id AND reports.limit_date <= '#{DateTime.now.to_s}'")
      .group("inspections.id").having('count(reports.id) = ?', value[0])
    else
      records
    end
  }

  filter :state_name, apply: ->(records, value, _options) {
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

  filter :field_chief, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? ActionController::Parameters and value[0]["full_name"].present?
        records.joins("LEFT OUTER JOIN users as field_chiefs ON field_chiefs.id = inspections.expert_id")
        .where("field_chiefs.first_name || ' ' || field_chiefs.last_name ilike '%" + value[0]["full_name"] + "%'")
      else
        records
      end
    else
      records
    end
  }

  filter :administrator, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? ActionController::Parameters and value[0]["full_name"].present?
        records.joins("INNER JOIN users as administrators ON administrators.id = inspections.expert_id")
        .where("administrators.first_name || ' ' || administrators.last_name ilike '%" + value[0]["full_name"] + "%'")
      else
        records
      end
    else
      records
    end
  }




  filter :construction, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? ActionController::Parameters and value[0][:name].present?
        records.joins(:construction).where("constructions.name ilike '%" + value[0]["name"] + "%'")
      else
        records
      end
    else
      records
    end
  }

  filter :company, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? ActionController::Parameters and value[0][:name].present?
        records.joins(construction: :company).where("companies.name ilike '%" + value[0]["name"] + "%'")
      else
        records
      end
    else
      records
    end
  }

  filter :formatted_created_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(inspections.created_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :formatted_resolved_at, apply: ->(records, value, _options) {
    records
  }

  filter :formatted_final_signed_at, apply: ->(records, value, _options) {
    if not value.empty?
      records.where("to_char(inspections.final_signed_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

  filter :num_reports, apply: ->(records, value, _options) {
    if not value.empty?
      records = records.joins("FULL OUTER JOIN reports ON reports.inspection_id = inspections.id")
      .group("inspections.id").having('count(reports.id) = ?', value[0])
    else
      records
    end
  }

  filter :creator, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? ActionController::Parameters and value[0]["full_name"].present?
        records.joins("INNER JOIN users as creators ON creators.id = inspections.creator_id")
          .where("creators.first_name || ' ' || creators.last_name ilike '%" + value[0]["full_name"] + "%'")
      else
        records
      end
    else
      records
    end
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
      records.where("to_char(inspections.created_at, 'DD/MM/YYYY HH:MI') similar to '%(" + value.join("|") + ")%'")
    else
      records
    end
  }

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
