source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.19.0'
# Use Puma as the app server
gem 'puma', '~> 3.6', '>= 3.6.2'
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
gem 'dotenv-rails', '~> 2.1', '>= 2.1.1'

gem 'activerecord-postgis-adapter', '~> 4.0', '>= 4.0.2'
gem 'paranoia', '~> 2.2'
gem 'versionist', '~> 1.5'
gem 'jsonapi-resources', git: 'https://github.com/cerebris/jsonapi-resources', branch: 'master'

gem 'fog', '~> 1.38'
gem 'sidekiq', '~> 4.2', '>= 4.2.7'
gem 'redis', '~> 3.3', '>= 3.3.2'
gem 'wicked_pdf', '~> 1.1'
gem 'wkhtmltopdf-binary', '~> 0.12.3.1'
gem 'charlock_holmes', '~> 0.7.3'

gem 'activeuuid', '~> 0.6.1'
gem 'devise', '~> 4.2'
gem 'doorkeeper', '~> 4.2'

gem 'awesome_print', '~> 1.7'
gem 'rack-cors', '~> 0.4.0'
gem 'acts_as_list', '~> 0.8.2'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
 gem 'byebug', '~> 9.0', '>= 9.0.6', platform: :mri
end

group :development do
  gem 'listen', '~> 3.1', '>= 3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0'
  gem 'spring-watcher-listen', '~> 2.0', '>= 2.0.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
