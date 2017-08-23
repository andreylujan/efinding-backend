# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: collections
#
#  id                   :integer          not null, primary key
#  name                 :text
#  parent_collection_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organization_id      :integer
#

class Collection < ApplicationRecord

  require 'csv_utils'
  belongs_to :parent_collection,
    class_name: :Collection, foreign_key: :parent_collection_id
  has_many :children, class_name: :Collection, foreign_key: :parent_collection_id, dependent: :destroy
  belongs_to :organization
  has_many :collection_items, -> { order(position: :asc) }, dependent: :destroy
  has_many :menu_items, dependent: :destroy
  validates :organization, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization }
  has_many :children, class_name: :Collection, foreign_key: :parent_collection_id

  def column_translations
    @column_translations ||= {
      code: "Código",
      parent_code: parent_collection.present? ? "Código #{parent_collection_name}" : "",
      name: "Nombre item"
    }
  end

  def parent_collection_name
    if parent_collection.present?
      parent_collection.name
    else
      ""
    end
  end

  def to_csv(file_name=nil)
    attributes = %w{code name parent_code}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: self.organization.csv_separator) do |csv|
      csv << attributes.map { |attr| column_translations[attr.to_sym] }
      collection_items.each do |item|
        csv << item.to_csv(attributes)
      end
    end
    if file_name.present?
      f = File.open(file_name, 'w')
      f.write(csv_obj)
      f.close
    end
    csv_obj
  end

  def row_to_hash(row)
    hash = {

    }
    hash[column_translations[:code]] = row[0]
    hash[column_translations[:name]] = row[1]
    if row.length > 2 and row[2].present?
      hash[column_translations[:parent_code]] = row[2]
    end
    hash
  end

  def from_csv(file_name, current_user)

    upload = BatchUpload.create! user: current_user, uploaded_file: file_name,
      uploaded_resource_type: "#{self.name}"

    csv_text = CsvUtils.read_file(file_name)
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: false, encoding: "UTF-8", col_sep: self.organization.csv_separator })
    rescue => exception
      raise exception.message
    end

    csv.each_with_index do |row, index|
      if index > 0
        CollectionItem.find_or_initialize_by(code: row[0], collection_id: self.id).tap do |item|
          item.name = row[1]
          if row.length > 2 and row[2].present?
            parent_item = CollectionItem.find_by_code_and_collection_id!(row[2], self.parent_collection_id)
            item.parent_item = parent_item
            item.parent_code = parent_item.code
          end

          errors = {}
          begin
            item.save!
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
            row_number: row_number, row_data: row_to_hash(row),
            created: created, changed: changed
          row_number = row_number + 1

          resources << csv_resource

          # items << item
          # resources << JSONAPI::ResourceSerializer.new(Api::V1::CsvUploadResource)
          # .serialize_to_hash(Api::V1::CsvUploadResource.new(csv_resource, nil))
        end
      end
    end
    resources
  end
end
