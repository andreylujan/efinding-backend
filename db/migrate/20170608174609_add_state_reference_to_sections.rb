class AddStateReferenceToSections < ActiveRecord::Migration[5.0]
  def change
    add_reference :sections, :state, foreign_key: true
    Section.all.each do |section|
      section.state = section.report_type.initial_state
      section.save!
    end
    remove_column :sections, :report_type_id
  end
end
