ActiveAdmin.register TableColumn do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count

end
