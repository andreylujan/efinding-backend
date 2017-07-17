r = ReportType.find(1)
r.sections.each do |section|
new_section = section.dup
new_section.report_type = Organization.last.report_types.first
new_section.save!
section.data_parts.each do |data_part|
new_data_part = data_part.dup
new_data_part.section = new_section
new_data_part.save!
end
end