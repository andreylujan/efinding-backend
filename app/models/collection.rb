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
  belongs_to :parent_collection,
    class_name: :Collection, foreign_key: :parent_collection_id
  belongs_to :organization
  has_many :collection_items, -> { order(position: :asc) }
  validates :organization, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization }

  def to_csv(file_name=nil)
    attributes = %w{code parent_code name}
    csv_obj = CSV.generate(headers: true,
    encoding: "UTF-8", col_sep: '|') do |csv|
      csv << attributes
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

  def from_csv(file_name, current_user)

    upload = BatchUpload.create! user: current_user, uploaded_file: file_name,
      uploaded_resource_type: "#{self.name}"

    csv_text = CsvUtils.read_file(file_name)
    headers = %w{code parent_code name}
    resources = []
    row_number = 2

    begin
      csv = CSV.parse(csv_text, { headers: true, encoding: "UTF-8", col_sep: '|' })
    rescue => exception
      raise exception.message
    end

    csv.each do |row|
      CollectionItem.find_or_initialize_by(code: row["code"], collection_id: self.id).tap do |item|
        item.name = row["name"]
        if row["parent_code"].present?
          parent_item = CollectionItem.find_by_code!(row["parent_code"])
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
          row_number: row_number, row_data: row.to_h,
          created: created, changed: changed
        row_number = row_number + 1

        resources << csv_resource

        # items << item
        # resources << JSONAPI::ResourceSerializer.new(Api::V1::CsvUploadResource)
        # .serialize_to_hash(Api::V1::CsvUploadResource.new(csv_resource, nil))
      end
    end
    resources
  end
end
