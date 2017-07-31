# -*- encoding : utf-8 -*-
class RenameMonthInAccidentRates < ActiveRecord::Migration[5.0]
  def change
  	rename_column :accident_rates, :month, :rate_period
  end
end
