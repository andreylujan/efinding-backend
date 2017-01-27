class Api::V1::InspectionResource < ApplicationResource

  has_one :creator
  has_one :construction
  has_many :users
  has_one :initial_signer
  has_one :final_signer
  has_one :company
  has_one :field_chief
  has_one :expert

  attributes :created_at, :resolved_at, 
    :state,
    :pdf, :pdf_uploaded,
    :formatted_created_at,
    :formatted_resolved_at,
    :formatted_final_signed_at,
    :num_pending_reports,
    :num_reports,
    :num_expired_reports,
    :field_chief_name,
    :administrator_name,
    :expert_name

  def field_chief_name
    @model.field_chief.name if @model.field_chief.present?
  end

  def administrator_name
    @model.construction.administrator.name if @model.construction.administrator.present?
  end

  def expert_name
    @model.expert.name if @model.expert.present?
  end

  def num_expired_reports
    @model.reports.count
  end

  add_foreign_keys :construction_id

  def pdf
    @model.pdf.url
  end

  filter :num_expired_reports, apply: ->(records, value, _options) {
    records
  }

  filter :field_chief_name, apply: ->(records, value, _options) {
    records
  }

  filter :administrator_name, apply: ->(records, value, _options) {
    records
  }

  filter :expert_name, apply: ->(records, value, _options) {
    records
  }

  filter :construction, apply: ->(records, value, _options) {
    records
  }

  filter :company, apply: ->(records, value, _options) {
    records
  }

  filter :formatted_created_at, apply: ->(records, value, _options) {
    records
  }

  filter :formatted_resolved_at, apply: ->(records, value, _options) {
    records
  }

  filter :formatted_final_signed_at, apply: ->(records, value, _options) {
    records
  }

  filter :num_pending_reports, apply: ->(records, value, _options) {
    records
  }

  filter :num_reports, apply: ->(records, value, _options) {
    records
  }

  filter :creator, apply: ->(records, value, _options) {
    if not value.empty?
      if value[0].is_a? Hash and value[0]["full_name"].present?
        records.includes(:creator).where("creators_inspections.first_name || ' ' || creators_inspections.last_name ilike '%" + value[0]["full_name"] + "%'")
        .where.not(creator_id: nil).references(:users)

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
