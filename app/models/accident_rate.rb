# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: accident_rates
#
#  id              :integer          not null, primary key
#  construction_id :integer          not null
#  rate_period     :date             not null
#  man_hours       :float
#  worker_average  :float
#  num_accidents   :integer
#  num_days_lost   :integer
#  accident_rate   :float
#  casualty_rate   :float
#  frequency_index :float
#  gravity_index   :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

class AccidentRate < ApplicationRecord
  attr_accessor :month
  attr_accessor :year
  belongs_to :construction
  belongs_to :organization
  validates :rate_period, presence: true
  validates :man_hours, presence: true
  validates :worker_average, presence: true
  validates :num_accidents, presence: true
  validates :num_days_lost, presence: true
  validates :accident_rate, presence: true
  validates :casualty_rate, presence: true
  validates :construction, presence: true
  validates :rate_period, uniqueness: { scope: :construction }
  validates :organization, presence: true

  before_validation :set_period
  before_save :calculate_indexes

  def self.column_translations
    @column_translations ||= {
      construction_code: "Código de obra",
      month: "Mes",
      year: "Año",
      man_hours: "Horas hombre",
      worker_average: "Promedio de trabajadores",
      num_accidents: "Número de accidentes",
      num_days_lost: "Número de días perdidos",
      accident_rate: "Tasa de accidentabilidad",
      casualty_rate: "Tasa de siniestralidad",
      frequency_index: "Índice de frecuencia",
      gravity_index: "Índice de gravedad",
      num_total_workers: "Cantidad de trabajadores del mes empresa"
    }
  end

  def construction_code
    construction.code
  end

  def self.row_to_hash(headers, row)
    hash = {

    }
    headers.each_with_index do |header, index|
      hash[column_translations[header.to_sym]]  = row[index]
    end
    hash
  end


  def self.from_csv(file_name, current_user)

    upload = BatchUpload.create! user: current_user, uploaded_file: file_name,
      uploaded_resource_type: "accidentabilidad"

    csv_text = CsvUtils.read_file(file_name)
    headers = %w{construction_code month year man_hours worker_average num_accidents
      num_days_lost accident_rate casualty_rate num_total_workers}
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: false, encoding: "UTF-8", col_sep: current_user.organization.csv_separator })
    rescue => exception
      raise exception.message
    end

    csv.each_with_index do |row, index|
      if index > 0 and row.length > 0 and row[0].present?
        construction_code = row[0]
        construction = Construction.find_by_code(construction_code)
        if construction.present?
          AccidentRate.find_or_initialize_by(construction_id: construction.id,
          rate_period: Date.new(row[2].to_i, row[1].to_i)).tap do |item|

            item.man_hours = row[3].gsub(",", ".").to_f
            item.worker_average = row[4].gsub(",", ".").to_f
            item.num_accidents = row[5].to_i
            item.num_days_lost = row[6].to_i
            item.accident_rate = row[7].gsub(",", ".").to_f
            item.casualty_rate = row[8].gsub(",", ".").to_f
            if row[9].present?
              global_data = MonthlyGlobalData.find_or_initialize_by(month_date: item.rate_period, organization: current_user.organization)
              global_data.num_workers = row[9].to_i
              global_data.save!
            end

            item.organization = current_user.organization

            errors = {}
            begin
              item.save!
            rescue => e
              errors = item.errors.as_json
            end


            created = false
            changed = false
            success = true
            if not errors.empty?
              success = false
            elsif item.previous_changes[:id].present?
              created = true
            elsif item.previous_changes.any?
              changed = true
            end

            csv_resource = CsvUpload.new id: item.id, success: success,
              errors: errors,
              row_number: row_number, row_data: row_to_hash(headers, row),
              created: created, changed: changed
            row_number = row_number + 1

            resources << csv_resource

            # items << item
            # resources << JSONAPI::ResourceSerializer.new(Api::V1::CsvUploadResource)
            # .serialize_to_hash(Api::V1::CsvUploadResource.new(csv_resource, nil))
          end
        else
          csv_resource = CsvUpload.new id: nil, success: false,
            errors: { "obra" => [ "No existe una obra con el código #{construction_code}"] },
            row_number: row_number, row_data: row.to_h,
            created: false, changed: false
          row_number = row_number + 1

          resources << csv_resource
        end
      end
    end
    resources
  end

  def num_total_workers
    global_data = MonthlyGlobalData.find_by(month_date: rate_period, organization: organization)
    if global_data.present?
      global_data.num_workers
    end
  end

  def self.to_csv(current_user, file_name=nil)
    attributes = %w{construction_code month year man_hours worker_average num_accidents
      num_days_lost accident_rate casualty_rate num_total_workers frequency_index gravity_index}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: current_user.organization.csv_separator) do |csv|
      csv << attributes.map { |attr| column_translations[attr.to_sym] }
      current_user.organization.accident_rates.each do |item|
        csv << attributes.map do |column_name|
          item.month = item.rate_period.month
          item.year = item.rate_period.year
          item.send column_name
        end
      end
    end
    if file_name.present?
      f = File.open(file_name, 'w')
      f.write(csv_obj)
      f.close
    end
    csv_obj
  end

  private
  def set_period
    if year.present? and month.present?
      self.rate_period = Date.new(year.to_i, month.to_i)
    end
  end

  def calculate_indexes
    self.frequency_index = man_hours > 0 ? (1000000*num_accidents).to_f/man_hours.to_f : -1
    self.gravity_index = man_hours > 0 ? (1000000*num_days_lost).to_f/man_hours.to_f : -1
  end
end
