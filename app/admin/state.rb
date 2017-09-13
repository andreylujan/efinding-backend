# -*- encoding : utf-8 -*-
ActiveAdmin.register State do
  controller do
    define_method :permitted_params do
      params.permit!
    end
  end


  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
 

  index do
    column :id
    column :name
    column :report_type
    column :color do |state|
      raw("<span style='color: #{state.color};'>#{state.color}</span>")
    end
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
      f.input :show_pdf
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
