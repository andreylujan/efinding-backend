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
  after_save :update_users, on: [ :update ]
  @previos_expert
  def upcase_code
    if self.code.present?
      self.code = self.code.strip.upcase
    end
  end

  def expert_id
    return if experts.empty?
    experts.first["id"]
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



  def update_users
    Rails.logger.info "UPDATE USERS #{self.id}"

    @previos_experts = self.experts_was
    _constructions = Construction.find(self.id)

    Rails.logger.info "----------------------------------"
    Rails.logger.info "PREVIO WAS #{self.experts_was}" #[1,2,3]
    Rails.logger.info "AHORA #{_constructions.experts}" #[1,2]
    Rails.logger.info "----------------------------------"

    arr = self.experts_was
    _constructions.experts.map do |p|
      arr.delete(p)
    end

    arr.map do |p|
       Rails.logger.info "----------------------------------"
       Rails.logger.info "ELIMINAR todo el estado anterior de : #{p["id"]} #{p["name"]}"
       user = User.find(p["id"])
       construction = user.constructions
       cons = construction.find{|c|c['code']== self.code}
       Rails.logger.info "Construccion:"
       Rails.logger.info "#{cons}"
       user.constructions.delete(cons)
       user.roles = []
       user.save
       Rails.logger.info "----------------------------------"
    end

    arr2 =  _constructions.experts
    self.experts_was.map do |p|
      arr2.delete(p)
    end

    #Añadir a las construcciones siempre que no existan
    arr2.map do |p|
      Rails.logger.info "----------------------------------"
      Rails.logger.info "AÑADIR todo el estado anterior de : #{p["id"]} #{p["name"]}"

      user = User.find(p["id"])
      construction = []
      if user.constructions.kind_of?(Array)
        construction = user.constructions
      end

      cons = construction.find{|c|c['code']== self.code}

      if not cons.present?
        rol = user.role_id

        admin = false
        experto = false
        jefe = false

        if rol == 1
          admin = true
        end

        if rol == 2

          jefe = true
        end
        if rol == 3
          experto = true
        end

        Rails.logger.info "construccion: asiganaion de cosas #{construction.kind_of?(Array)}"


        construction << {:id => self.id,:company_id => self.company_id, :code => self.code, :name => self.name,
          :roles => {:experto => {:active => experto, :base => experto}, :administrador => {:active => admin, :base => admin}, :jefe => {:active => jefe, :base => jefe}}}
        Rails.logger.info "construccion: #{construction}"
          user.constructions = construction

        user.save
        Rails.logger.info "#{user.constructions}"
        Rails.logger.info "----------------------------------"
      else


        Rails.logger.info "#{cons}"

        cons["name"] = self.name

        cnn = []
        construction.map do |c|
          if c["code"] == cons["code"]
            cnn << cons
          else
            cnn << c
          end
        end

        user.constructions = cnn
        user.save
      end
    end
  end

  def userroles
    users = []
    self.experts.map do |c|
      user = User.find(c["id"])
      roles = []
      user.constructions.map do |x|
        if self.id == x["id"]
          roles = x["roles"]
        end
      end
      users <<  {:id =>  user.id , :fullName => user.full_name, :roles => roles}
    end
    return users
  end

end
