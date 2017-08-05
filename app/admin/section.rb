ActiveAdmin.register Section do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :section_type
      f.input :position
      f.input :state
      f.input :config, as: :text, input_html: { value: controller.instance_variable_get(:@section).config.to_json, class: 'jsoneditor-target' }
    end
    f.actions
  end
end
