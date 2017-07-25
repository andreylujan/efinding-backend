class AddOrganizationIdToAccidentRates < ActiveRecord::Migration[5.0]
  def change
    add_reference :accident_rates, :organization, foreign_key: true
    AccidentRate.all.each do |rate|
    	rate.organization = rate.construction.company.organization
    	rate.save!
    end
  end
end
