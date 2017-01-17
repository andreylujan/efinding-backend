class AddPositionToMenuItems < ActiveRecord::Migration[5.0]
  def change
    add_column :menu_items, :position, :integer
    MenuItem.order(:updated_at).each.with_index(1) do |menu_item, index|
    	menu_item.update_column :position, index
    end
  end
end
