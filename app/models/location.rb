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

class Location < ApplicationRecord

	attr_accessor :longitude, :latitude
	before_create :set_lonlat

	def set_lonlat
		if not longitude.nil? and not latitude.nil?
			self.lonlat = "POINT(#{longitude} #{latitude})"
		else
			self.lonlat = "POINT(-33.443988 -70.655401)"
		end
	end
end
