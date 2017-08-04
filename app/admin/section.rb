ActiveAdmin.register Section do
  permit_params :name, :config, :state_id


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at


  form do |f|
    f.inputs do
      f.input :name
      f.input :config, as: :text, input_html: { value: controller.instance_variable_get(:@section).config.to_json, class: 'jsoneditor-target' }
    end
    f.actions
  end
end
