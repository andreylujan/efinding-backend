# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: regions
#
#  id            :integer          not null, primary key
#  name          :text             not null
#  roman_numeral :text             not null
#  number        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Region < ApplicationRecord
	has_many :communes
end
