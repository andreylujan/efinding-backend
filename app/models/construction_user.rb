# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: construction_users
#
#  id              :integer          not null, primary key
#  construction_id :integer          not null
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ConstructionUser < ApplicationRecord
  belongs_to :construction
  belongs_to :user
end
