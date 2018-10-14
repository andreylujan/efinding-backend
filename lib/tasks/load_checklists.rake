
namespace :db do
  desc "Loads and creates the checklist from the db/checklists.csv"
  task :load_checklists => :environment do
    require "csv"

    sections = []
    current_section = nil

    CSV.foreach("db/checklists.csv") do |row|
    	row = row.select { |r| r.present? }
    	if row.length == 1
    		if current_section
    			sections << current_section
    		end
    		parts = row[0].strip.split
    		current_section = {
    			id: parts[0].gsub(".", ""),
    			name: parts[1..-1].join(" "),
    			items: []
    		}
    	elsif row.length > 1
    		current_section[:items] << {
    			id: row[0],
    			name: row[1]
    		}
    	end
    end

    checklist = Checklist.first
    organization = Organization.first || Organization.new(id: 1, name: "Moller", default_admin_path: "/")
    if checklist.present?
    	checklist.update_attribute :sections, sections
    else
      Checklist.create!(organization: organization, sections: sections)
    end
  end
end
