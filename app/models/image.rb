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
# Indexes
#
#  index_images_on_category_id    (category_id)
#  index_images_on_report_id      (report_id)
#  index_images_on_resource_id    (resource_id)
#  index_images_on_resource_type  (resource_type)
#  index_images_on_uuid           (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_8d4663ed8c  (report_id => reports.id)
#  fk_rails_9dab9b62a6  (category_id => categories.id)
#

class Image < ApplicationRecord

  # mount_base64_uploader :image, ImageUploader
  belongs_to :category
  belongs_to :report
  # validates_presence_of :image
  validates_presence_of :url
  belongs_to :resource, polymorphic: true

  def http_url
  	self.url.gsub 'https', 'http' if self.url.present?
  end
  # before_create :write_image_identifier
  # skip_callback :save, :before, :write_image_identifier

end
