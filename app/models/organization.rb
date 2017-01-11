# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: organizations
#
#  id                     :integer          not null, primary key
#  name                   :text             not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  default_role_id        :integer
#  admin_url              :text
#  default_report_type_id :integer
#  database               :text
#  has_new_button         :boolean          default(TRUE), not null
#  logo                   :text
#  csv_separator          :text             default("|"), not null
#
# Indexes
#
#  index_organizations_on_default_role_id  (default_role_id)
#  index_organizations_on_name             (name) UNIQUE
#

class Organization < ApplicationRecord

    has_many :roles
    has_many :categories
    has_many :report_types
    has_many :data_parts
    has_many :report_columns
    has_many :organization_data, dependent: :destroy
    has_many :menu_sections

    belongs_to :default_role, class_name: :Role, foreign_key: :default_role_id
    belongs_to :default_report_type, class_name: :ReportType, foreign_key: :default_report_type_id

    def users
    	User.joins(:role)
    	.where(roles: { organization_id: self.id })
    end
end
