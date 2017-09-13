# -*- encoding : utf-8 -*-
class CreateAppMenuItems < ActiveRecord::Migration[5.0]
  def change
    create_table :app_menu_items do |t|
      t.references :organization, foreign_key: true, null: false
      t.text :name, null: false
      t.integer :position
      t.text :icon
      t.text :url_include, null: false
      t.boolean :filter_creator, null: false, default: false
      t.boolean :filter_assigned_user, null: false, default: false

      t.timestamps
    end
  end
end
