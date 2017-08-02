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

  def construction_code
    construction.code
  end

  def month
    rate_period.month
  end

  def year
    rate_period.year
  end

  def self.from_csv(file_name, current_user)

    upload = BatchUpload.create! user: current_user, uploaded_file: file_name,
      uploaded_resource_type: "accidentabilidad"

    csv_text = CsvUtils.read_file(file_name)
    headers = %w{construction_code month year man_hours worker_average num_accidents
      num_days_lost accident_rate casualty_rate}
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: true, encoding: "UTF-8", col_sep: current_user.organization.csv_separator })
    rescue => exception
      raise exception.message
    end

    csv.each do |row|
      construction_code = row["construction_code"]
      construction = Construction.find_by_code(construction_code)
      if construction.present?
        AccidentRate.find_or_initialize_by(construction_id: construction.id,
        rate_period: Date.new(row["year"].to_i, row["month"].to_i)).tap do |item|

          item.man_hours = row["man_hours"].to_f
          item.worker_average = row["worker_average"].to_f
          item.num_accidents = row["num_accidents"].to_i
          item.num_days_lost = row["num_days_lost"].to_i
          item.accident_rate = row["accident_rate"].to_f
          item.casualty_rate = row["casualty_rate"].to_f
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
            row_number: row_number, row_data: row.to_h,
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
    resources
  end

  def self.to_csv(current_user, file_name=nil)
    attributes = %w{construction_code month year man_hours worker_average num_accidents
      num_days_lost accident_rate casualty_rate frequency_index gravity_index}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: current_user.organization.csv_separator) do |csv|
      csv << attributes
      current_user.organization.accident_rates.each do |item|
        csv << attributes.map do |column_name|
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
