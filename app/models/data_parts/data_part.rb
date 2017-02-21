# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: data_parts
#
#  id            :integer          not null, primary key
#  type          :text             not null
#  name          :text             not null
#  icon          :text
#  required      :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  config        :json             not null
#  position      :integer          default(0), not null
#  detail_id     :integer
#  section_id    :integer
#  collection_id :integer
#

class DataPart < ApplicationRecord
  
  belongs_to :section
  acts_as_list scope: :section
  belongs_to :collection

end
