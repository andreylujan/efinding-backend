class AddPositionToMenuSections < ActiveRecord::Migration[5.0]
  def change
    add_column :menu_sections, :position, :integer
    MenuSection.order(:updated_at).each.with_index(1) do |menu_section, index|
    	menu_section.update_column :position, index
    end
  end
end
