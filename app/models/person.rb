# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  rut        :text
#  name       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Person < ApplicationRecord
end
