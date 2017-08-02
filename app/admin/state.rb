ActiveAdmin.register State do
  permit_params :name


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  filter :created_at
  form do |f|
    f.inputs do
      f.input :name
      f.input :color
    end
    f.actions
  end

  index do
    column :id
    column :name
    column :report_type
    column :color
    column :show_pdf
    column :incoming_transitions do |state|
      links = []
      state.incoming_transitions.each do |transition|
        links << (link_to transition.name, admin_state_transition_path(transition))
      end
      raw(links.join("<br>"))
    end
    column :outgoing_transitions do |state|
      links = []
      state.outgoing_transitions.each do |transition|
        links << (link_to transition.name, admin_state_transition_path(transition))
      end
      raw(links.join("<br>"))
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :organization
      f.input :name
      f.input :position
      f.has_many :menu_items do |menu_item|
        menu_item.inputs
      end
    end
    f.actions
  end


end
