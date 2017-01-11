# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  device_token    :text
#  registration_id :text
#  uuid            :text
#  architecture    :text
#  address         :text
#  locale          :text
#  manufacturer    :text
#  model           :text
#  name            :text
#  os_name         :text
#  processor_count :integer
#  version         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  os_type         :text
#
# Indexes
#
#  index_devices_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_410b63ef65  (user_id => users.id)
#

class Device < ApplicationRecord
  belongs_to :user
  after_create :destroy_old_devices
  validates_uniqueness_of :device_token, allow_nil: true
  validates_uniqueness_of :registration_id, allow_nil: true

  def destroy_old_devices
    user = self.user
    if user.nil?
      return
    end

    Device.where(uuid: self.uuid)
    .where.not(id: self.id, uuid: nil)
    .destroy_all

    devices = user.devices.where(name: self.name)
    .order("created_at ASC")
    while devices.count > 5
      devices.first.destroy!
      devices = user.devices.where(name: self.name)
      .order("created_at ASC")
    end
  end
end
