ActiveAdmin.register StateTransition do
  permit_params :name, :previous_state_id, :next_state_id


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at



end
