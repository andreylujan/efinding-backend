# -*- encoding : utf-8 -*-
Rails.application.routes.draw do

  match '/*path', to: 'application#cors_preflight_check', via: :options
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  use_doorkeeper do
    skip_controllers :sessions, :authorizations, :applications,
      :authorized_applications, :token_info
    controllers :tokens => 'tokens'
  end

  namespace :api do
    namespace :v1 do
      namespace :manflas do
        jsonapi_resources :stations, only: [ :index ] do
        end
      end

      jsonapi_resources :checkins, only: [ :create ] do
      end

      jsonapi_resources :collections, only: [ :index, :show, :create, :update, :destroy ] do
        jsonapi_related_resources :collection_items
        # jsonapi_resources :collection_items, only: [ :index, :show, :create, :update, :destroy ] do
        # end
      end

      jsonapi_resources :collection_items, only: [ :show, :create, :update, :destroy ] do
      end


      jsonapi_resources :checkouts, only: [ :create ] do
      end

      jsonapi_resources :batch_uploads, only: [ :index ] do
      end

      jsonapi_resources :checklist_reports, only: [ :create, :index, :show ] do
      end

      jsonapi_resources :checklists, only: [ :index, :create, :update, :destroy, :show ] do
      end

      jsonapi_resources :personnel, only: [ :index, :create, :show, :update, :destroy ] do
      end

      jsonapi_resources :personnel_types, only: [ :index ] do
      end

      jsonapi_resources :organizations, only: [ :index, :show ] do
        jsonapi_related_resources :roles, only: [ :index ]
        jsonapi_related_resources :report_types, only: [ :index ]
        jsonapi_resources :users, only: [ :index ]
      end

      jsonapi_resources :report_types, only: [] do
        jsonapi_resources :reports, only: [ :index ] do
        end
      end

      jsonapi_resources :reports, only: [ :create, :index, :show, :update, :destroy ] do
        collection do
          get :zip
          get :xlsx
          get :mine
          get :tasks
        end
      end

      jsonapi_resources :report_types, only: [ :index ] do
      end

      jsonapi_resources :roles, only: :index
      jsonapi_resources :invitations, only: [
        :create,
        :update
      ]

      jsonapi_resources :companies, only: [ :index, :create, :update, :destroy, :show ] do
        jsonapi_resources :constructions, only: [ :index ] do
        end
      end

      jsonapi_resources :constructions, only: [ :index, :create, :update, :destroy, :show ] do
        collection do
          post :construction_personnel, to: "constructions#create_personnel"
          get :construction_personnel, to: "constructions#get_personnel"
        end
      end

      jsonapi_resources :table_columns, only: [ :index ] do
      end

      jsonapi_resources :inspections, only: [ :index, :create, :show, :update, :destroy ] do
        jsonapi_resources :reports, only: [ :index ] do
        end

        member do
          post :transition
        end
      end

      jsonapi_resources :data_parts, only: [ :index ] do
      end

      jsonapi_resources :images, only: [ :create ] do
      end

      jsonapi_resources :sections, only: [ :show, :index ] do
      end

      jsonapi_resources :devices, only: [ :create, :update ] do
      end

      jsonapi_resources :regions, only: [ :index ] do
      end

      jsonapi_resources :menu_sections, only: [ :index ] do
      end

      jsonapi_resource :dashboard, only: [ :show ]

      post :csv, to: 'csv#create'

      resources :users, only: [
        :create,
        :update,
        :show,
        :index,
        :destroy
      ] do
        collection do
          post :reset_password_token
          get :all
          get :verify
        end
        member do
          put :password
        end
      end
    end
  end
end
