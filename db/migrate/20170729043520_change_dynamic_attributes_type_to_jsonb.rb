class ChangeDynamicAttributesTypeToJsonb < ActiveRecord::Migration[5.0]
  def change
  	change_column :reports, :dynamic_attributes, :jsonb
  end
end
