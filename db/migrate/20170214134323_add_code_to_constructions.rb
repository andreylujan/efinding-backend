class AddCodeToConstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :constructions, :code, :text
    add_index :constructions, :code, unique: true
  end
end
