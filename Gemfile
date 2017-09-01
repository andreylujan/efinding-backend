source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'openssl'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.19.0'
# Use Puma as the app server
gem 'puma', '~> 3.7', '>= 3.7.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem 'dotenv-rails', '~> 2.2'

gem "rails-observers", github: 'rails/rails-observers'
gem 'mongoid'
gem 'activerecord-postgis-adapter', '~> 4.0', '>= 4.0.2'
gem 'paranoia', '~> 2.2', '>= 2.2.1'
gem 'versionist', '~> 1.5'
gem 'jsonapi-resources', git: 'https://github.com/cerebris/jsonapi-resources', ref: 'd9fdcb3fcdd2b5c39722e6d772ca7f4bf6272702'
gem 'fog', '~> 1.38'
gem 'fog-aws', '~> 1.2', '>= 1.2.1'
gem 'sidekiq', '~> 4.2', '>= 4.2.7'
gem 'redis', '~> 3.3', '>= 3.3.2'
gem 'wicked_pdf', '~> 1.1'
gem 'wkhtmltopdf-binary', '~> 0.12.3.1'
gem 'charlock_holmes', '~> 0.7.3'
gem 'rut_chileno', git: 'https://github.com/Numerico/rut-chileno', ref: '157d9d4aacfe9cac7f001007acaf9664ba20567f'

gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin'
gem 'jsoneditor-rails', '~> 1.0', '>= 1.0.1'
gem 'turbolinks', '~> 5.0', '>= 5.0.1'
gem 'sass', '~> 3.5', '>= 3.5.1'

gem "mini_magick"
gem 'devise', '~> 4.2'
gem 'doorkeeper', '~> 4.2'
gem 'ruby_kml', git: 'https://github.com/pelluch/ruby_kml'
gem 'rgeo', '~> 0.6.0'
gem 'awesome_print', '~> 1.7'
gem 'rack-cors', '~> 0.4.0'
gem 'acts_as_list', '~> 0.8.2'
gem 'paperclip', '~> 5.1'
gem 'aws-sdk', '~> 2.6', '>= 2.6.44'
gem 'carrierwave', '~> 1.0'
gem 'acts_as_xlsx', git: 'https://github.com/straydogstudio/acts_as_xlsx'
gem 'axlsx', '~> 2.0', '>= 2.0.1'
gem 'active_model_serializers', '~> 0.10.4'
gem 'jsonapi-serializers', '~> 0.16.1'
gem 'state_machines-activerecord'
gem 'faraday', '~> 0.13.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 9.0', '>= 9.0.6', platform: :mri
  gem 'listen', '~> 3.1', '>= 3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0'
  gem 'spring-watcher-listen', '~> 2.0', '>= 2.0.1'
end

group :development do
  gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'  
  gem 'capistrano-rails', '~> 1.2', '>= 1.2.1'
  gem 'capistrano-rbenv', '~> 2.1'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-sidekiq', git: 'https://github.com/pelluch/capistrano-sidekiq'
  gem 'rails-erd', '~> 1.5', require: false
  gem 'annotate', git: 'https://github.com/ctran/annotate_models.git', branch: 'develop'
  gem 'whenever', '~> 0.9.7', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
