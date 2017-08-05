ActiveAdmin.register Checklist do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  index do
  	column :id
  	column :organization
  	column :name
  	column :created_at
  	column :updated_at
  	actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :organization
      f.input :sections, as: :text, input_html: { value: checklist.sections.to_json, class: 'jsoneditor-target' }
    end
    f.actions
  end
end
