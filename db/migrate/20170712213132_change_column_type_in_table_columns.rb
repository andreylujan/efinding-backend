class ChangeColumnTypeInTableColumns < ActiveRecord::Migration[5.0]
  def change
  	remove_column :table_columns, :headers
  	add_column :table_columns, :headers, :json, null: false, default: []
  end
end
