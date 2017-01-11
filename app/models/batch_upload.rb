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

class BatchUpload < ApplicationRecord
  belongs_to :user

  has_attached_file :uploaded_file, default_url: "/batch_uploads/uploaded_files/:filename"
  has_attached_file :result_file, default_url: "/batch_uploads/result_files/:filename"

  validates_attachment_file_name :uploaded_file, matches: [/csv\z/, /CSV\z/]
  validates_attachment_file_name :result_file, matches: [/csv\z/, /CSV\z/]

  def uploaded_file_url
  	uploaded_file.url if uploaded_file.present?
  end

  def result_file_url
  	result_file.url if result_file.present?
  end

  def uploaded_file_size
  	uploaded_file_file_size
  end

  def result_file_size
  	result_file_file_size
  end
end
