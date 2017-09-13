# -*- encoding : utf-8 -*-
ActiveAdmin.register Inspection do


  controller do
    define_method :permitted_params do
      params.permit!
    end
  end



end
