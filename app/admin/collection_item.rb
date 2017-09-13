# -*- encoding : utf-8 -*-
ActiveAdmin.register CollectionItem do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  

end
