class AddColumnToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :role_id, :integer, default: 0 , null: false
    Inspection.reset_column_information
    inspections = Inspection.all
    inspections.map do |i|
      i.update_column :role_id, i.creator.role_id
    end
  end
end
