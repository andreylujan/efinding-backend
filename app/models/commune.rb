# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: communes
#
#  id         :integer          not null, primary key
#  region_id  :integer
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Commune < ApplicationRecord
  belongs_to :region
end
