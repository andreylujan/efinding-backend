# -*- encoding : utf-8 -*-
class AddSequentialIdToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :sequential_id, :integer
  end
end
