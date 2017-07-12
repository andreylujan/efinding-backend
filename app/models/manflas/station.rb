# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: batch_uploads
#
#  id                         :integer          not null, primary key
#  user_id                    :integer          not null
#  uploaded_resource_type     :text
#  uploaded_file_file_name    :string
#  uploaded_file_content_type :string
#  uploaded_file_file_size    :integer
#  uploaded_file_updated_at   :datetime
#  result_file_file_name      :string
#  result_file_content_type   :string
#  result_file_file_size      :integer
#  result_file_updated_at     :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Manflas::Station
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :style, type: Hash
  field :coordinates, type: Array
  field :polygon, type: Array
  field :sector, type: String
  field :variety, type: String

  def as_json(args)
  	json = super
  	json.delete("description")
  	json
  end

  def html
    @html ||= Nokogiri::HTML(description)
  end

  def plantation_year
    html.xpath('//tr/td[contains(text(), "Año_de_pl")]/following-sibling::td').text.strip
  end

  def plantation_density
    w = "%.2f" % html.xpath('//tr/td[contains(text(), "Distancia")]/following-sibling::td').text.strip.gsub(",", ".").to_f
    h = "%.2f" % html.xpath('//tr/td[contains(text(), "Distanci_1")]/following-sibling::td').text.strip.gsub(",", ".").to_f
    "#{w.to_s.gsub('.', ',')} x #{h.to_s.gsub('.', ',')}"
  end

  def last_year_production
    html.xpath('//tr/td[contains(text(), "Producció")]/following-sibling::td').text.strip
  end

  def water_precipitation
    html.xpath('//tr/td[contains(text(), "Precipitac")]/following-sibling::td').text.strip
  end
end
