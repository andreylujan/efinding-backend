ActiveAdmin.register TableColumn do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count

  form do |f|
  	f.input :organization
  	f.input :field_name
  	f.input :column_name
  	f.input :position
  	f.input :relationship_name
  	f.input :data_type
  	f.input :collection_name
  	f.input :collection_source
  	f.input :headers, as: :text, input_html: { value: table_column.headers.to_json, class: 'jsoneditor-target' }
  	actions
  end
	
end
