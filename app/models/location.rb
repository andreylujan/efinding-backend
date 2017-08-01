# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  lonlat     :geometry({:srid= not null, point, 0
#  accuracy   :float
#  timestamp  :integer
#  provider   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  address    :text
#  region     :text
#  commune    :text
#  reference  :text
#  altitude   :float
#

class Location < ApplicationRecord

  attr_accessor :longitude, :latitude
  before_create :set_lonlat

  before_save :reverse_geocode

  def set_lonlat
    if longitude and latitude
      self.lonlat = "POINT(#{longitude} #{latitude})"
    end
  end

  def reverse_geocode
    if lonlat.present? and (address.nil? or region.nil? or commune.nil?)
      results = Geocoder.search("#{lonlat.y},#{lonlat.x}")
      if results.length > 0
        result = results[0]
        if address.nil?
          self.address = result.data["formatted_address"]
        end
        result.data["address_components"].each do |component|
          if component["types"][0] == "locality" and component["types"][1] == "political" and commune.nil?
            self.commune = component["short_name"]
          end
          if component["types"][0] == "administrative_area_level_1" and component["types"][1] == "political" and region.nil?
            self.region = component["short_name"]
          end
        end
      end
    end
  end
end
