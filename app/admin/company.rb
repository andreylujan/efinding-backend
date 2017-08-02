ActiveAdmin.register Company do
  permit_params :name
  permit_params :organization_id

  

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at
  filter :organization

  

end
