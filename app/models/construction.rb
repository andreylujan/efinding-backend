# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: constructions
#
#  id               :integer          not null, primary key
#  name             :text             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :integer
#  administrator_id :integer
#  code             :text
#  deleted_at       :datetime
#  supervisor_id    :integer
#

class Construction < ApplicationRecord
  acts_as_paranoid
  belongs_to :company
  has_many :accident_rates, dependent: :destroy
  has_many :inspections, dependent: :destroy
  validates :company, presence: true
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :company }
  belongs_to :administrator, class_name: :User, foreign_key: :administrator_id
  belongs_to :supervisor, class_name: :User, foreign_key: :supervisor_id
  # belongs_to :visitor, class_name: :Person, foreign_key: :visitor_id
  has_and_belongs_to_many :contractors
  has_many :construction_personnel, dependent: :destroy
  accepts_nested_attributes_for :construction_personnel
  has_many :personnel, through: :construction_personnel
  has_many :checklist_reports, dependent: :destroy
  has_many :construction_users, dependent: :destroy
  has_many :users, through: :construction_users
  validate :check_expert


  before_create :upcase_code

  def expert_names
    users.experts.map { |u| u.name }
  end

  def formatted_expert_names
    expert_names.join(", ")
  end

  def has_expert?
    users.any? { |u| u.role.expert? }
  end

  def check_expert
    if not users.any? { |u| u.role.expert? }
      errors.add("Jefe de terreno", "Debe existir al menos un jefe de terreno")
    end
  end

  def upcase_code
    if self.code.present?
      self.code = self.code.strip.upcase
    end
  end

  def construction_personnel_attributes=(val)
    self.construction_personnel.each { |p| p.destroy! }
    val.select! { |v| v.key?("personnel_id") and v.key?("personnel_type_id") }
    super
  end

  def self.personnel_to_csv(file_name, current_user)
    attributes = %w{code personnel_type_id personnel_id}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: current_user.organization.csv_separator) do |csv|
      csv << attributes
      Construction.includes(:construction_personnel).each do |construction|
        construction.construction_personnel.each do |personnel|
          csv << [
            construction.code,
            personnel.personnel_type_id,
            personnel.personnel_id
          ]
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

  def self.personnel_from_csv(file_name, current_user)

    upload = BatchUpload.create! user: current_user, uploaded_file: file_name,
      uploaded_resource_type: "Obras"

    csv_text = CsvUtils.read_file(file_name)


    headers = %w{code personnel_type_id personnel_id}
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: true, encoding: "UTF-8", col_sep: current_user.organization.csv_separator })
    rescue => exception
      raise exception.message
    end

    ids = []

    csv.each do |row|

      errors = {}
      construction = Construction.find_by_code(row["code"])

      if construction.present?



        new_personnel = []
        item = ConstructionPersonnel.find_or_initialize_by(construction_id: construction.id,
        personnel_type_id: row["personnel_type_id"]).tap do |cp|
          cp.personnel_id = row["personnel_id"]
        end

        begin
          item.save!
          ids << item.id
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


      else
        csv_resource = CsvUpload.new id: item.id, success: false,
          errors: { code: "Obra con código #{row['code']} no existe" },
          row_number: row_number, row_data: row.to_h,
          created: false, changed: false
        row_number = row_number + 1
      end
      resources << csv_resource
    end

    ConstructionPersonnel.where.not(id: ids).destroy_all
    resources
  end

  def self.column_translations
    @column_translations ||= {
      company_id: "ID empresa",
      code: "Código",
      administrator_email: "Email administrador de obra",
      expert_emails: "Emails Jefes de Terreno (separados por ,)",
      inspector_emails: "Emails inspectores (separados por ,)",
      supervisor_email: "Email APR"
    }
  end

  def self.to_csv(current_user, file_name=nil)
    attributes = %w{company_id code name administrator_email expert_emails inspector_emails supervisor_email}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: current_user.organization.csv_separator) do |csv|
      csv << attributes.map { |attr| column_translations[attr.to_sym] }
      Construction.joins(:company).where(companies: { organization_id: current_user.organization_id }).each do |construction|
        csv << [
          construction.company.id,
          construction.code,
          construction.name,
          construction.administrator.present? ? construction.administrator.email : "SIN ADMINISTRADOR",
          construction.users.experts.map { |u| u.email }.join(","),
          construction.users.inspectors.map { |u| u.email }.join(","),
          construction.supervisor.present? ? construction.supervisor.email : "SIN SUPERVISOR"
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
      uploaded_resource_type: "Obras"
    csv_text = CsvUtils.read_file(file_name)

    headers = %w{company_id code name administrator_email expert_emails inspector_emails supervisor_email}
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: false, encoding: "UTF-8", col_sep: current_user.organization.csv_separator })
    rescue => exception
      raise exception.message
    end

    csv.each_with_index do |row, index|
      if index > 0

        errors = {}
        cons = Construction.find_or_initialize_by(company_id: row[0], code: row[1]).tap do |construction|
          construction.name = row[2]
          has_errors = false
          expert_ids = construction.user_ids.dup
          inspector_ids = construction.user_ids.dup
          begin
            construction.company = Company.find(row[0])
          rescue => e
            errors = {
              company_id: [ e.message ]
            }
            has_errors = true
          end
          begin
            construction.administrator = User.find_by_email!(row[3])
          rescue => e
            errors[:administrator_email] = [ e.message ]
            has_errors = true
          end
          begin
            if row[4].present?
              row[4].strip.split(",").each do |email|
                user = User.find_by_email!(email)
                if user.organization_id == current_user.organization_id
                  expert_ids << user.id
                end
              end
            end
          rescue => e
            errors[:expert_emails] << e.message
            has_errors = true
          end
          begin
            if row[5].present?
              row[5].strip.split(",").each do |email|
                user = User.find_by_email!(email)
                if user.organization_id == current_user.organization_id
                  inspector_ids << user.id
                end
              end
            end
          rescue => e
            errors[:expert_emails] << e.message
            has_errors = true
          end
          begin
            construction.supervisor = User.find_by_email!(row[6])
          rescue => e
            errors[:supervisor_email] = [ e.message ]
            has_errors = true
          end
          if not has_errors
            begin
              Construction.transaction do
                construction.user_ids = inspector_ids | expert_ids
                construction.save!
              end
            rescue => e
              errors = construction.errors.as_json
            end
          end
        end

        created = false
        changed = false
        success = true
        if not errors.empty?
          success = false
        elsif cons.previous_changes[:id].present?
          created = true
        elsif cons.previous_changes.any?
          changed = true
        end

        csv_resource = CsvUpload.new id: cons.id, success: success,
          errors: errors,
          row_number: row_number, row_data: row_to_hash(headers, row),
          created: created, changed: changed
        row_number = row_number + 1
        resources << csv_resource
      end
    end

    resources
  end
end
