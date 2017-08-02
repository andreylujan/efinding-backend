# -*- encoding : utf-8 -*-
Organization.find(1).collections.where(parent_collection: nil).each do |collection|
new_collection = collection.dup
new_collection.organization = Organization.last
new_collection.save!
collection.children.each do |child|

new_child_1 = child.dup
new_child_1.parent_collection = new_collection
new_child_1.save!
child.children.each do |subchild|
new_child_2 = subchild.dup
new_child_2.parent_collection = new_child_1
new_child_2.save!
end
end
end

r = ReportType.find(1)
r.sections.each do |section|
new_section = section.dup
new_section.report_type = Organization.last.report_types.first
new_section.save!
section.data_parts.each do |data_part|
new_data_part = data_part.dup
new_data_part.section = new_section
new_data_part.collection = nil
new_data_part.save!
end
end
