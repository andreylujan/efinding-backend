# -*- encoding : utf-8 -*-
ActiveAdmin.register MenuItem do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count



end
