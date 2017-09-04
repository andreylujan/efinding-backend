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
#  state_id      :integer
#  selected      :boolean          default(FALSE), not null
#

class Image < ApplicationRecord

  # mount_base64_uploader :image, ImageUploader
  acts_as_paranoid
  belongs_to :report
  before_validation :generate_id
  # validates_presence_of :image
  validates_presence_of :url
  belongs_to :resource, polymorphic: true
  belongs_to :state

  before_save :assign_state
  # before_save :fix_rotation, on: [ :create ]

  def http_url
    self.url.gsub 'https', 'http' if self.url.present?
  end

  def fix_rotation
    if is_processed?
      return
    end
    image = MiniMagick::Image.open(self.url)
    if image.exif.present?
      image.auto_orient
      image.strip
    end
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

    client = Aws::S3::Client.new(region: ENV['AWS_REGION'])
    bucket = Aws::S3::Bucket.new(ENV['AMAZON_BUCKET'], client: client)
    key = "images/#{SecureRandom.uuid}"
    if extension.present?
      key = "#{key}.#{extension}"
    end
    object = bucket.put_object(key: key, body: image.tempfile)
    self.url = "#{ENV['AMAZON_CDN']}#{key}"
    self.is_processed = true
  end

  def generate_id
    if self.id.nil?
      self.id = SecureRandom.uuid
    end
  end

  # before_create :write_image_identifier
  # skip_callback :save, :before, :write_image_identifier
  private
  def assign_state
    if report.present? and state.nil?
      self.state = report.state
    end
  end
end
