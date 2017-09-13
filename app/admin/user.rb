# -*- encoding : utf-8 -*-
ActiveAdmin.register User do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end


  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :created_at
    column :role
    column :image
    actions
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :password
      f.input :password_confirmation
      f.input :role
      f.input :image
    end
    f.actions
  end

end
