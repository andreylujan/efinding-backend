# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  lonlat     :geometry({:srid= not null, point, 0
#  accuracy   :integer
#  timestamp  :integer
#  provider   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  address    :text
#  region     :text
#  commune    :text
#  reference  :text
#
# Indexes
#
#  index_locations_on_lonlat  (lonlat)
#

class Location < ApplicationRecord

	attr_accessor :longitude, :latitude
	before_create :set_lonlat

	def set_lonlat
		if longitude and latitude
			self.lonlat = "POINT(#{longitude} #{latitude})"
		end
	end
end
