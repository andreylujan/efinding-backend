# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: checklists
#
#  id              :integer          not null, primary key
#  name            :text
#  sections        :json             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer          not null
#  options         :jsonb            not null
#

class Checklist < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :sections, presence: true
  has_many :checklist_reports
  before_save :assign_ids
  validate :sections_is_array

  def formatted_created_at
    created_at.strftime("%d/%m/%Y %R")
  end

  private

  def assign_section_ids(section)
    section["items"].each do |item|
      if not item["id"].present?
        item["id"] = SecureRandom.uuid.to_s
        if item["items"].present?
          assign_section_ids(item)
        end
      end
    end
  end
  
  def assign_ids
    sections.each do |section|
      if not section["id"].present?
        section["id"] = SecureRandom.uuid.to_s
      end
      assign_section_ids(section)
    end
  end

  def sections_is_array
    if not sections.present? or not sections.is_a? Array
      errors.add(:sections, "sections debe ser un arreglo no vacío")
    end
  end
end
