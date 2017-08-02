ActiveAdmin.register Image do
  

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at

  
  index do
    selectable_column
    id_column
    column :url
    column :image do |image|
      image_tag image.url
    end
    column :created_at
    actions

  end

end
