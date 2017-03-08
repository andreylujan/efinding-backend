class AddEmailToPersonnel < ActiveRecord::Migration[5.0]
  def change
    add_column :personnel, :email, :text
  end
end
