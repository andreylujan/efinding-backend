ActiveAdmin.register Report do


  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  index do
  	column :id
  	column :created_at
  	column :creator
  	column :limit_date
  	column :finished
  	column :assigned_user
  	column :pdf
  	column :pdf_uploaded
  	column :finished_at
  	column :inspection
  	column :html
  	column :resolved_at
  	column :resolver
  	column :resolution_comment
  	column :initial_location_image
  	column :final_location_image
  	column :scheduled_at
  	column :state
  	actions
  end

  form do |f|
    f.inputs do
      f.input :inspection
      f.input :creator
      f.input :limit_date
      f.input :finished
      f.input :assigned_user
      f.input :pdf
      f.input :pdf_uploaded
      f.input :html
      f.input :started_at
      f.input :finished_at

      f.input :resolver
      f.input :resolved_at
      f.input :initial_location_image
      f.input :final_location_image
      f.input :scheduled_at
      f.input :state
      f.input :dynamic_attributes, as: :text, input_html: { value: report.dynamic_attributes.to_json, class: 'jsoneditor-target' }
    end
    f.actions
  end


end
