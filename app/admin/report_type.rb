ActiveAdmin.register ReportType do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  form do |f|
    f.inputs do
      f.input :organization
      f.input :name
      f.input :title_field
      f.input :initial_state
      f.input :subtitle_field
      f.input :default_title
      f.input :default_subtitle
      f.input :has_pdf
      f.has_many :states do |new_state|
        new_state.inputs
      end
      f.input :default_dynamic_attributes, as: :text, input_html: { value: report_type.default_dynamic_attributes.to_json, class: 'jsoneditor-target' }
      
    end
    f.actions
  end


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count



end
