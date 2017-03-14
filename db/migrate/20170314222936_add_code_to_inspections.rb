class AddCodeToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :code, :integer
    add_index :inspections, :code

    Construction.all.each do |c|
      c.inspections.order('created_at ASC').each_with_index do |i, idx|
      	i.code = (idx + 1)
      	i.save!
      end
    end
  end
end
