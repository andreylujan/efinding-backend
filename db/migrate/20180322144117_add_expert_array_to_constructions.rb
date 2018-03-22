class AddExpertArrayToConstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :constructions, :experts, :json, default: {} , null: false
    Construction.reset_column_information
    constructions = Construction.all
    constructions.each do |const|
      expert = []
      if const.expert_id.present?
        user = User.find(const.expert_id)
        expert << {:id => user.id, :name => user.full_name}
        const.update_column :experts, expert
      end
  	end
  end
end
