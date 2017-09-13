# -*- encoding : utf-8 -*-
ActiveAdmin.register MenuSection do


  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count


  index do
    column :name
    column :organization
    column :admin_path
    column :icon
    column :menu_items do |menu_section|
      links = []
      menu_section.menu_items.each do |menu_item|
        links << (link_to menu_item.name, besito_menu_item_path(menu_item))
      end
      raw(links.join("<br>"))
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :organization
      f.input :name
      f.input :admin_path
      f.input :position
      f.input :icon
      f.has_many :menu_items do |menu_item|
        menu_item.inputs
      end
    end
    f.actions
  end

end
