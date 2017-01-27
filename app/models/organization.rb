# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: organizations
#
#  id            :integer          not null, primary key
#  name          :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  logo          :text
#  csv_separator :text             default("|"), not null
#

class Organization < ApplicationRecord

    has_many :roles
    has_many :categories
    has_many :report_types
    has_many :data_parts
    has_many :table_columns, -> { order(position: :asc) }
    has_many :organization_data, dependent: :destroy
    has_many :menu_sections, -> { order(position: :asc) }
    has_many :companies
    has_many :reports, through: :report_types
    has_many :users, through: :roles
    
    def users
    	User.joins(:role)
    	.where(roles: { organization_id: self.id })
    end
end
