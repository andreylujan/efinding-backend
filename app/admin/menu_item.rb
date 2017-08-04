ActiveAdmin.register MenuItem do
  permit_params :name, :menu_section_id, :position, :admin_path,
  	:url_include,
  	:collection_id,
  	:collection_name

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at



end
