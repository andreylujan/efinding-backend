ActiveAdmin.register Checklist do
  permit_params :name, :organization_id, :sections


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at
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
