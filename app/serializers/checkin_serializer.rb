# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: checkins
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  arrival_time   :datetime         not null
#  exit_time      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  data           :json             not null
#  arrival_lonlat :geometry({:srid= point, 0
#  exit_lonlat    :geometry({:srid= point, 0
#
# Indexes
#
#  index_checkins_on_arrival_lonlat  (arrival_lonlat)
#  index_checkins_on_exit_lonlat     (exit_lonlat)
#  index_checkins_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_4b2b85ec8b  (user_id => users.id)
#

class CheckinSerializer < ActiveModel::Serializer
	attributes :arrival_time, :exit_time, :user_id, :data,
		:arrival_lonlat, :exit_lonlat
end
