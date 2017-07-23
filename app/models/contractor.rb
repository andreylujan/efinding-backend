# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: contractors
#
#  id              :integer          not null, primary key
#  name            :text             not null
#  rut             :text
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Contractor < ApplicationRecord
  belongs_to :organization
  validates :name, presence: true, uniqueness: { scope: :organization }
  validates :rut, uniqueness: { scope: :organization, allow_nil: true }
  validates :organization, presence: true
  has_and_belongs_to_many :constructions

  # validate :correct_rut
  before_save :format_rut

  def correct_rut
    if rut.present?
      unless RUT::validar(self.rut)
        errors.add(:rut, "Formato de RUT inválido")
      end
    end
  end

  def format_rut
    if rut.present? and RUT::validar(rut)
      self.rut = RUT::formatear(RUT::quitarFormato(self.rut).gsub(/^0+|$/, ''))
    end
  end

  def self.to_csv(current_user, file_name=nil)
    attributes = %w{rut name}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: current_user.organization.csv_separator) do |csv|
      csv << attributes
      current_user.organization.contractors.each do |contractor|
        csv << [
          contractor.rut,
          contractor.name
        ]
      end
    end
    if file_name.present?
      f = File.open(file_name, 'w')
      f.write(csv_obj)
      f.close
    end
    csv_obj
  end

  def self.from_csv(file_name, current_user)

    upload = BatchUpload.create! user: current_user, uploaded_file: file_name,
      uploaded_resource_type: "Contratistas"
    csv_text = CsvUtils.read_file(file_name)

    headers = %w{rut name}
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: true, encoding: "UTF-8", col_sep: current_user.organization.csv_separator })
    rescue => exception
      raise exception.message
    end

    csv.each do |row|

      errors = {}
      contractor = nil

      if row["rut"].present?
        contractor = Contractor.find_by_rut(row["rut"])
      end

      if contractor.nil?
        contractor = Contractor.new(organization: current_user.organization)
      end
      
      contractor.name = row["name"]
      if row["rut"].present?
        contractor.rut = row["rut"]
      end

      begin
        contractor.save!
      rescue => e
        errors = contractor.errors.as_json
      end

      created = false
      changed = false
      success = true
      if not errors.empty?
        success = false
      elsif contractor.previous_changes[:id].present?
        created = true
      elsif contractor.previous_changes.any?
        changed = true
      end

      csv_resource = CsvUpload.new id: contractor.id, success: success,
        errors: errors,
        row_number: row_number, row_data: row.to_h,
        created: created, changed: changed
      row_number = row_number + 1
      resources << csv_resource
    end

    resources
  end
end
