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
#  config        :jsonb            not null
#  position      :integer          default(0), not null
#  detail_id     :integer
#  collection_id :integer
#  list_id       :integer
#

class DatePicker < DataPart
    	
end