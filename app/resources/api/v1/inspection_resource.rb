class Api::V1::InspectionResource < JSONAPI::Resource

  has_one :creator
  has_one :construction
  
  attributes :created_at, :resolved_at

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

end
