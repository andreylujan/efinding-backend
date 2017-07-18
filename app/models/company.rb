# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: companies
#
#  id              :integer          not null, primary key
#  name            :text
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  rut             :text
#  deleted_at      :datetime
#

class Company < ApplicationRecord
  acts_as_paranoid
  belongs_to :organization
  validates :organization, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization }
  has_many :constructions, dependent: :destroy

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
    attributes = %w{id name}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: current_user.organization.csv_separator) do |csv|
      csv << attributes
      current_user.organization.companies.each do |company|
        csv << [
          company.id,
          company.name
          
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
      uploaded_resource_type: "Empresas"
    csv_text = CsvUtils.read_file(file_name)

    headers = %w{id name}
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: true, encoding: "UTF-8", col_sep: current_user.organization.csv_separator })
    rescue => exception
      raise exception.message
    end

    csv.each do |row|

      errors = {}
      company = nil
      if row["id"].present?
        company = Company.find_by_id(row["id"])
      end

      if company.nil?
        company = Company.new(organization: current_user.organization)
      end
      company.name = row["name"]

      begin
        company.save!
      rescue => e
        errors = company.errors.as_json
      end

      created = false
      changed = false
      success = true
      if not errors.empty?
        success = false
      elsif company.previous_changes[:id].present?
        created = true
      elsif company.previous_changes.any?
        changed = true
      end

      csv_resource = CsvUpload.new id: company.id, success: success,
        errors: errors,
        row_number: row_number, row_data: row.to_h,
        created: created, changed: changed
      row_number = row_number + 1
      resources << csv_resource
    end

    resources
  end
end
