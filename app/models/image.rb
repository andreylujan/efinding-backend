# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: images
#
#  id            :uuid             not null, primary key
#  url           :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  report_id     :uuid
#  resource_id   :integer
#  resource_type :text
#  comment       :text
#  is_initial    :boolean          default(TRUE), not null
#  deleted_at    :datetime
#

class Image < ApplicationRecord

  # mount_base64_uploader :image, ImageUploader
  acts_as_paranoid
  belongs_to :report
  before_validation :generate_id
  # validates_presence_of :image
  validates_presence_of :url
  belongs_to :resource, polymorphic: true

  def http_url
  	self.url.gsub 'https', 'http' if self.url.present?
  end

  def generate_id
    if self.id.nil?
      self.id = SecureRandom.uuid
    end
  end
  
  # before_create :write_image_identifier
  # skip_callback :save, :before, :write_image_identifier

end
