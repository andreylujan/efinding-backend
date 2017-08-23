ActiveAdmin.register PdfTemplate do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  index do
  	column :id
  	column :name
  	column :report_type
  	actions
  end

  show do |pdf_template|
  	raw(pdf_template.template)

  end
  
  

end
