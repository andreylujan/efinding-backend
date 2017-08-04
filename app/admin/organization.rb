ActiveAdmin.register Organization do
  permit_params :name, :default_admin_path,
  	:csv_separator, :app_name, :default_report_type

  

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at

  

end
