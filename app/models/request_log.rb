# == Schema Information
#
# Table name: request_logs
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  url             :text             not null
#  status_code     :integer
#  response_body   :text
#  error_message   :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class RequestLog < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :url, presence: true
end
