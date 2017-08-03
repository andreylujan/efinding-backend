# -*- encoding : utf-8 -*-
class Api::V1::CompanyResource < ApplicationResource
  attributes :name, :company_name
  has_one :organization
  def company_name
    @model.name
  end
  before_save do
    @model.organization = context[:current_user].organization if @model.new_record?
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    companies = Company.where(organization_id: current_user.organization_id)
    if not current_user.is_superuser? and not current_user.role.can_view_all?
      if context[:all] != "true" and context[:from] != :show
        if current_user.role.supervisor?
          companies = companies.joins(:constructions)
          .where(constructions: { supervisor_id: current_user.id })
        elsif current_user.role.expert?
          companies = companies.joins(:constructions)
          .joins("INNER JOIN construction_users expert_construction_users ON constructions.id = expert_construction_users.construction_id")
          .joins("INNER JOIN users expert_users ON expert_users.id = expert_construction_users.user_id")
          .where("expert_users.id = ?", current_user.id)
        elsif current_user.role.inspector?
          companies = companies.joins(:constructions)
          .joins("INNER JOIN construction_users inspection_construction_users ON constructions.id = inspection_construction_users.construction_id")
          .joins("INNER JOIN users inspector_users ON inspector_users.id = inspection_construction_users.user_id")
          .where("inspector_users.id = ?", current_user.id)
        elsif current_user.role.administrator?
          companies = companies.joins(:constructions)
          .where(constructions: { administrator_id: current_user.id })
        else
          companies = Company.none
        end
      end
    end
    companies
  end

end

