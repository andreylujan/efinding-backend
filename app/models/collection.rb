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
	belongs_to :collection
	has_many :collection_items
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

  	def from_csv(file_name)
  		csv_text = file_name.read
  		file_name.close
  		headers = %w{code parent_code name}
  		CSV.parse(csv_text, { headers: true, col_sep: '|' }) do |row|
  			CollectionItem.find_or_initialize_by(code: row["code"], collection_id: self.id).tap do |item|
  				item.name = row["name"]
  			end
  		end
  	end
end
