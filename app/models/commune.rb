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
# Indexes
#
#  index_communes_on_region_id           (region_id)
#  index_communes_on_region_id_and_name  (region_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_9f434ab280  (region_id => regions.id)
#

class Commune < ApplicationRecord
  belongs_to :region
end
