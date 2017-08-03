# -*- encoding : utf-8 -*-
class Api::V1::ConstructionResource < ApplicationResource
  attributes :name, :company_id, :code, :construction_personnel_attributes, :contractors_array,
    :experts_array
  has_one :company
  add_foreign_keys :company_id, :administrator_id, :supervisor_id

  has_one :administrator
  has_one :supervisor
  has_many :construction_personnel
  has_many :contractors
  has_many :users

  def contractors_array
    @model.contractors.order("name ASC").map { |u| { name: u.name, rut: u.rut, id: u.id } }
  end

  filter :company_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.where(company_id: value[0])
    else
      records
    end
  }

  def experts_array
    @model.users.experts.order("name ASC").map { |u| { name: u.name, rut: u.rut, id: u.id } }
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    if context[:company_id]
      constructions = Company.find(context[:company_id]).constructions
    else
      constructions = Construction.joins(company: :organization)
      .where(organizations: { id: context[:current_user].organization.id })
    end
    if not current_user.is_superuser? and not current_user.role.can_view_all?
      if context[:all] != "true" and context[:from] != :show
        if current_user.role.supervisor?
          constructions = constructions.where(supervisor_id: current_user.id)
        elsif current_user.role.expert?
          constructions = constructions.joins("INNER JOIN construction_users expert_construction_users ON constructions.id = expert_construction_users.construction_id")
          .joins("INNER JOIN users inspector_users ON inspector_users.id = expert_construction_users.user_id")
          .where("inspector_users.id = ?", current_user.id)
        elsif current_user.role.inspector?
          constructions = constructions.joins("INNER JOIN construction_users inspection_construction_users ON constructions.id = inspection_construction_users.construction_id")
          .joins("INNER JOIN users inspector_users ON inspector_users.id = inspection_construction_users.user_id")
          .where("inspector_users.id = ?", current_user.id)
        elsif current_user.role.administrator?
          constructions = constructions.where(administrator_id: current_user.id)
        else
          byebug
          constructions = Construction.none
        end
      end
    end
    constructions
  end

  def fetchable_fields
    super - [ :construction_personnel_attributes ]
  end
end
