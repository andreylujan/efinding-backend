# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: batch_uploads
#
#  id                         :integer          not null, primary key
#  user_id                    :integer          not null
#  uploaded_resource_type     :text
#  uploaded_file_file_name    :string
#  uploaded_file_content_type :string
#  uploaded_file_file_size    :integer
#  uploaded_file_updated_at   :datetime
#  result_file_file_name      :string
#  result_file_content_type   :string
#  result_file_file_size      :integer
#  result_file_updated_at     :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Manflas::Station
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :style, type: Hash
  field :coordinates, type: Array
  field :polygon, type: Array
  field :sector, type: String
  field :variety, type: String

  def as_json(args)
  	json = super
  	json.delete("description")
  	json
  end
end
