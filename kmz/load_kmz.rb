# -*- encoding : utf-8 -*-
kml = KMLFile.parse(File.read('./kmz/cuarteles/doc.kml'))
stations = kml.features[0].features[0].features
styles = {}
kml.features[0].styles.each do |style|
  styles[style.id] = style
end
stations.each_with_index do |station_data, idx|
  # Manflas::Station.where(name: station_data.name).each { |m| m.destroy! }

  polygon_info = kml.features[0].features[0].features[idx]
  description = station_data.description
  page = Nokogiri::HTML(description)
  tds = page.css('td')

  sector = ""
  variety = ""
  tds.each_with_index do |td, td_idx|
    if td.text.strip == 'SECTOR'
      sector = tds[td_idx + 1].text.strip
    elsif td.text.strip == 'Variedad'
      variety = tds[td_idx + 1].text.strip
    end
  end
  station = Manflas::Station.where(name: station_data.name).first
  if station.present?
    station.assign_attributes name: station_data.name,
      description: station_data.description,
      style: styles[polygon_info.style_url[1..-1]].as_json,
      # coordinates: station_data.geometry.coordinates[0...-1].map { |c| c.to_f },
      polygon: polygon_info.geometry.features[0].outer_boundary_is.coordinates.map { |c| [ c[0].to_f, c[1].to_f ] },
      sector: sector,
      variety: variety
    station.save!
  else
    asd
  end
end
