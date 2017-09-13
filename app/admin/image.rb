# -*- encoding : utf-8 -*-
ActiveAdmin.register Image do
    

  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  
  index do
    selectable_column
    id_column
    column :url
    column :state
    column :image do |image|
      image_tag image.url, { class: "img-thumbnail" }
    end
    column :created_at
    actions

  end

end
