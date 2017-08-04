ActiveAdmin.register CollectionItem do
  permit_params :name,
  	:collection_id,
  	:parent_item_id,
  	:position


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at

  

end
