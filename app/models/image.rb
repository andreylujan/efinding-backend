# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: images
#
#  id            :uuid             not null, primary key
#  url           :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  category_id   :integer
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
  belongs_to :category
  belongs_to :report
  # validates_presence_of :image
  validates_presence_of :url
  belongs_to :resource, polymorphic: true
  # after_commit :fix_rotation, on: [ :create ]
  # mount_uploader :url, ReportImageUploader
  before_save :set_id
  before_save :fix_rotation, on: [ :create ]

  def http_url
  	self.url.gsub 'https', 'http' if self.url.present?
  end
  # before_create :write_image_identifier
  # skip_callback :save, :before, :write_image_identifier

  def formatted_comment
    if comment.present? and comment.strip.present?
      comment
    else
      "Sin comentario"
    end
  end

  def fix_rotation
    image = MiniMagick::Image.open(self.url)
    if image.exif.present?
      max = image.width > image.height ? image.width : image.height
      if max > 1200
        scale = 1200.0/max
        scale = (scale*100).floor.to_s + "%"
        image.resize scale
      end
      extension = ""
      last_index = self.url.rindex(".")
      if last_index.present?
        extension = self.url.split(".")[-1]
      end
      image.auto_orient
      image.strip
      client = Aws::S3::Client.new(region: ENV['AWS_REGION'])
      bucket = Aws::S3::Bucket.new(ENV['AMAZON_BUCKET'], client: client)
      key = "images/#{SecureRandom.uuid}"
      if extension.present?
        key = "#{key}.#{extension}"
      end
      object = bucket.put_object(key: key, body: image.tempfile)
      self.url = "#{ENV['ASSET_HOST']}/#{key}"
    end
  end

  private
  def set_id
    if id.nil?
      self.id = SecureRandom.uuid
    end
  end
end
