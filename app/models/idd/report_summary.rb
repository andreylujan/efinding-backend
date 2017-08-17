# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: checkins
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  arrival_time   :datetime         not null
#  exit_time      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  data           :json             not null
#  arrival_lonlat :geometry({:srid= point, 0
#  exit_lonlat    :geometry({:srid= point, 0
#

class Idd::ReportSummary
  include ActiveModel::Model
  attr_accessor :id, :email, :num_reports, :name, :phone
end
