f = File.open('checklist-seremi.csv', 'r')
contents = f.read
f.close
csv = CSV.parse(contents)
sections = []
current_section = nil
csv.each do |row|
  row = row.select { |el| not el.nil? }
  if row.length == 0
    byebug
    a = 2
  else
    title = row[0].strip
    if title.index("$")
      if current_section.present?
        sections << current_section
      end
      current_section = {
        name: title.gsub("$", ""),
        items: []
      }
    else
      new_item = {
        name: title,
        items: []
      }

      if row.length > 1
        row[1..-1].each do |subitem|
          new_item[:items] << {
            name: subitem.strip
          }
        end
      end
      current_section[:items] << new_item
    end
  end
end
Checklist.find_or_initialize_by(organization_id: 5, name: "Checklist Seremí").tap do |checklist|
  checklist.sections = sections
  checklist.save!
end
