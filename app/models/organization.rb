# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: organizations
#
#  id                     :integer          not null, primary key
#  name                   :text             not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  logo                   :text
#  csv_separator          :text             default("|"), not null
#  checklist_id           :integer
#  default_admin_path     :text
#  default_report_type_id :integer
#  map_type               :integer          default("roadmap"), not null
#  app_name               :integer          default("echeckit"), not null
#

class Organization < ApplicationRecord

    has_many :roles
    has_many :report_types
    has_many :table_columns, -> { order(position: :asc) }
    has_many :menu_sections, -> { order(position: :asc) }
    has_many :companies, dependent: :destroy
    has_many :reports, dependent: :destroy
    has_many :users, through: :roles
    has_many :collections
    belongs_to :checklist
    has_many :checklists
    has_many :personnel_types
    belongs_to :default_report_type, class_name: :ReportType, foreign_key: :default_report_type_id

    enum map_type: [ :roadmap, :satellite ]
    enum app_name: [ :echeckit, :efinding ]

    validates :default_admin_path, presence: true
    
    def checklist_id
        if checklist.present?
            checklist.id
        end
    end

    def users
    	User.joins(:role)
    	.where(roles: { organization_id: self.id })
    end
end
