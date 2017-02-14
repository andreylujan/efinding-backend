# -*- encoding : utf-8 -*-
class RenameReportColumnsToTableColumns < ActiveRecord::Migration[5.0]
  def change
  	rename_table :report_columns, :table_columns
  	remove_column :table_columns, :report_type_id
  	add_column :table_columns, :collection_name, :text
  	add_column :table_columns, :collection_source, :integer
  end
end
