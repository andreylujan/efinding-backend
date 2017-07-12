class AddHeadersToTableColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :table_columns, :headers, :text, null: false, array: true, default: []
  end
end
