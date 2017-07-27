# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: images
#
#  id            :integer          not null, primary key
#  url           :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  category_id   :integer
#  report_id     :uuid
#  resource_id   :integer
#  resource_type :text
#  comment       :text
#  uuid          :text
#

class Api::V1::ImageResource < ApplicationResource
  
  has_one :category
  add_foreign_keys :report_id
  # has_one :report

  attributes :url, :comment, :report_id, :synced, :is_initial
  
  def synced
  	1
  end
  
  def fetchable_fields
  	super
  end

end
