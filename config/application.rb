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
require "sprockets/railtie"
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
    config.api_only = false

    config.autoload_paths += %W(#{config.root}/app/models/data_parts)
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'data_parts')]
    config.autoload_paths += Dir[Rails.root.join('app', 'serializers', 'data_parts')]
    config.autoload_paths += Dir[Rails.root.join('lib')]
    config.assets.paths << Rails.root.join("app", "assets")

    config.active_job.queue_adapter = :sidekiq

    # ActiveModelSerializers.config.adapter = :json_api
    # ActiveModelSerializers.config.key_transform = :underscore
    config.middleware.insert_before 0, :"Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options, :put, :patch, :delete]
      end
    end

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :user_name => ENV["SENDGRID_USER"],
      :password => ENV["SENDGRID_PASSWORD"],
      :domain => ENV["SENDGRID_DOMAIN"],
      :address => ENV["SENDGRID_ADDRESS"],
      :port => ENV["SENDGRID_PORT"],
      :authentication => :plain,
      :enable_starttls_auto => true
    }

  end
end
