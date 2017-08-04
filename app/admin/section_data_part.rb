ActiveAdmin.register SectionDataPart do
  permit_params :name, :section_id, :data_part_id


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at



end
