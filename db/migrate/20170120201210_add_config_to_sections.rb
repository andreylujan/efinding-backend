class AddConfigToSections < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :config, :json, null: false, default: {}
  end
end
