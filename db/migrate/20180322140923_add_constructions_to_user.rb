class AddConstructionsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :constructions, :json, default: {} , null: false
    User.reset_column_information
    users = User.all
    users.each do |user|
      constructions_filtered = []
      constructions = Construction.all
      constructions_filtered = constructions.where(expert_id: user.id).or(constructions.where(administrator_id: user.id)).or(constructions.where(supervisor_id: user.id))
      construction_array = []
      constructions_filtered.each do |const|
        const_code = const.code
        const_name = const.name
        if const.expert_id.present?
          base = false
          if user.role_id == 3
            base = true
          end
          expert_json = {:active => true, :base => base}
        else
          expert_json = {:active => false, :base => false}
        end

        if const.administrator_id.present?
          base = false
          if user.role_id == 4
            base = true
          end
          administrator_json = {:active => true, :base => base}
        else
          administrator_json = {:active => false, :base => false}
        end

        if const.supervisor_id.present?
          base = false
          if user.role_id == 2
            base = true
          end
          supervisor_json = {:active => true, :base => base}

        else
          supervisor_json = {:active => false, :base => false}
        end
        construction_array << {:code => const_code, :name => const_name,
          :roles => {:experto => expert_json, :administrador => administrator_json, :jefe => supervisor_json}}
      end
      user.update_column :constructions, construction_array
  	end
  end
end
