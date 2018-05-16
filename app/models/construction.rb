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
#  expert_id        :integer
#  deleted_at       :datetime
#  supervisor_id    :integer
#

class Construction < ApplicationRecord
  acts_as_paranoid
  belongs_to :company
  has_many :inspections, dependent: :destroy
  validates :company, presence: true
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :company }
  belongs_to :administrator, class_name: :User, foreign_key: :administrator_id
  belongs_to :expert, class_name: :User, foreign_key: :expert_id
  belongs_to :supervisor, class_name: :User, foreign_key: :supervisor_id
  belongs_to :inspector, class_name: :User, foreign_key: :inspector_id
  # belongs_to :visitor, class_name: :Person, foreign_key: :visitor_id
  has_and_belongs_to_many :contractors
  has_many :construction_personnel, dependent: :destroy
  accepts_nested_attributes_for :construction_personnel
  has_many :personnel, through: :construction_personnel
  has_many :checklist_reports, dependent: :destroy
  before_create :upcase_code

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

  def self.construction_to_csv(file_name=nil)
    attributes = %w{code name administrator_id administrator_name
        expert_id expert_name supervisor_id supervisor_name inspector_id inspector_name experts}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: ';') do |csv|
      csv << attributes
      Construction.includes(:construction_personnel).each do |construction|
          csv << [
            construction.code,
            construction.name,
            construction.administrator.present? ? construction.administrator.id : "",
            construction.administrator.present? ? construction.administrator.name : "",
            construction.expert.present? ? construction.expert_id : "",
            construction.expert.present? ? construction.expert.name : "",
            construction.supervisor.present? ? construction.supervisor.id : "",
            construction.supervisor.present? ? construction.supervisor.name : "",
            construction.inspector.present? ? construction.inspector_id : "",
            construction.inspector.present? ? construction.inspector.name : "",
            #construction.inspector_id.present? ? User.find(construction.inspector_id).name : "",
            #construction.experts.to_s
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

  def self.user_name(user_id)
    user = User.find(user_id)
    Rails.logger.info "User : #{user}"
    name = ""
    if user != nil
      name = user.name
    end
    name
  end

  def self.to_csv(file_name=nil)
    attributes = %w{code personnel_type_id personnel_id}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: '|') do |csv|
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

  def self.from_csv(file_name, current_user)

    upload = BatchUpload.create! user: current_user, uploaded_file: file_name,
      uploaded_resource_type: "Obras"

    csv_text = CsvUtils.read_file(file_name)


    headers = %w{code personnel_type_id personnel_id}
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: true, encoding: "UTF-8", col_sep: '|' })
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

  def UpdateUsers
    constructions = Construction.includes(:construction_personnel)
    constructions.each do |const|
      const_code = const.code
      const_name = const.name
      experts = const.experts
      experts.map do |exp|
        Rails.logger.info "Expert id : #{exp['id']}"
        if not exp['id'].present?
          return
        end
        user = User.find(exp['id'])
        Rails.logger.info "User : #{user}"
        constuct = user.constructions
        construction_array = []
        if constuct.present?
          constuct.map do |m|
            if m['code'] == const_code
              expert_json = {:active => true, :base => false}
              administrator_json = m['roles']['administrador']
              supervisor_json = m['roles']['jefe']
              construction_array << {:code => const_code, :name => const_name,
                :roles => {:experto => expert_json, :administrador => administrator_json, :jefe => supervisor_json}}
            else
              construction_array << m
            end
          end
        else
          const_code = const.code
          const_name = const.name
          if const.expert_id.present?
            base = false
            if user.role_id == 3
              base = true
            end
            expert_json = {:active => true, :base => base}
          else
            expert_json = {:active => false, :base => false}
          end

          if const.administrator_id.present?
            base = false
            if user.role_id == 4
              base = true
            end
            administrator_json = {:active => true, :base => base}
          else
            administrator_json = {:active => false, :base => false}
          end

          if const.supervisor_id.present?
            base = false
            if user.role_id == 2
              base = true
            end
            supervisor_json = {:active => true, :base => base}

          else
            supervisor_json = {:active => false, :base => false}
          end
          construction_array << {:code => const_code, :name => const_name,
            :roles => {:experto => expert_json, :administrador => administrator_json, :jefe => supervisor_json}}
        end
        user.update_column :constructions, construction_array
      end
    end
  end
end
