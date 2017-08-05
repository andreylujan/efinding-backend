ActiveAdmin.register DataPart do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count

  form do |f|
    f.inputs do
      f.input :type
      f.input :name
      f.input :icon
      f.input :required
      f.input :position
      f.input :collection
      f.input :list
      f.input :config, as: :text, input_html: { value: data_part.config.to_json, class: 'jsoneditor-target' }
    end
    f.actions
  end


end
