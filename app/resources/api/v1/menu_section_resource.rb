class Api::V1::MenuSectionResource < ApplicationResource
  attributes :name, :icon, :admin_path
  has_many :menu_items

  def self.records(options = {})
    context = options[:context]
    user = context[:current_user]
    user.organization.menu_sections
  end

end
