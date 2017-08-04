ActiveAdmin.register State do
  permit_params :name, :report_type_id,
    :color,
    :show_pdf


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
        links << (link_to transition.name, besito_state_transition_path(transition))
      end
      raw(links.join("<br>"))
    end
    column :outgoing_transitions do |state|
      links = []
      state.outgoing_transitions.each do |transition|
        links << (link_to transition.name, besito_state_transition_path(transition))
      end
      raw(links.join("<br>"))
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :report_type
      f.input :name
      f.input :color
      f.has_many :incoming_transitions do |transition|
        transition.inputs
      end
      f.has_many :outgoing_transitions do |transition|
        transition.inputs
      end
    end
    f.actions
  end


end
