# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: section_data_parts
#
#  id           :integer          not null, primary key
#  section_id   :integer          not null
#  data_part_id :integer          not null
#  editable     :boolean          default(TRUE), not null
#  position     :integer          default(1), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class SectionDataPart < ApplicationRecord
  acts_as_list scope: :section
  belongs_to :section
  belongs_to :data_part
end
