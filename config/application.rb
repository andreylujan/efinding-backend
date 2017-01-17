# -*- encoding : utf-8 -*-
require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'dotenv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dotenv.load

module Efinding
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.autoload_paths += %W(#{config.root}/app/models/data_parts)
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'data_parts')]
    config.autoload_paths += Dir[Rails.root.join('lib')]

    # ActiveModelSerializers.config.adapter = :json_api
    # ActiveModelSerializers.config.key_transform = :underscore
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options, :put, :patch, :delete]
      end
    end

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address        => 'smtp.office365.com',
        :port           => '587',
        :authentication => :login,
        :user_name      => ENV['EMAIL_USERNAME'],
        :password       => ENV['EMAIL_PASSWORD'],
        :domain         => 'ewin.cl',
        :enable_starttls_auto => true
    }


  end
end
