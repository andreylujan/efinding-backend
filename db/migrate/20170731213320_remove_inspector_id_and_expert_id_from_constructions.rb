class RemoveInspectorIdAndExpertIdFromConstructions < ActiveRecord::Migration[5.0]
  def change
  	Construction.all.each do |construction|
  		user_ids = construction.user_ids
  		if construction.inspector_id.present?
  			user_ids << construction.inspector_id
  		end
  		if construction.expert_id.present?
  			user_ids << construction.expert_id
  		end
  		construction.user_ids = user_ids
  		construction.save!
  	end
    remove_column :constructions, :inspector_id, :integer
    remove_column :constructions, :expert_id, :integer
  end
end
