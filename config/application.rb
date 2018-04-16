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
require "i18n/backend/fallbacks"

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

    config.active_job.queue_adapter = :sidekiq

    # ActiveModelSerializers.config.adapter = :json_api
    # ActiveModelSerializers.config.key_transform = :underscore
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options, :put, :patch, :delete]
      end
    end

    config.action_mailer.delivery_method = :smtp

    #config.action_mailer.smtp_settings = {
    #  :address        => 'smtp.office365.com',
    #  :port           => '587',
    #  :authentication => :login,
    #  :user_name      => ENV['EMAIL_USERNAME'],
    #  :password       => ENV['EMAIL_PASSWORD'],
    #  :domain         => 'ewin.cl',
    #  :enable_starttls_auto => true
    #}
    config.action_mailer.smtp_settings = {
      :user_name => ENV["SENDGRID_USER"],
      :password => ENV["SENDGRID_PASSWORD"],
      :domain => ENV["SENDGRID_DOMAIN"],
      :address => ENV["SENDGRID_ADDRESS"],
      :port => ENV["SENDGRID_PORT"],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
    config.i18n.fallbacks = true

    # Whitelist locales available for the application
    I18n.available_locales = [:"es-CL", :en]

    # Set default locale to something other than :en
    I18n.default_locale = :"es-CL"
    I18n.locale = :"es-CL"

    I18n.fallbacks.map(:"es-CL" => :en)

  end
end
