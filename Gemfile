source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'bootsnap', require: false
gem 'govuk_design_system_formbuilder', '~> 3.3.0'
gem 'importmap-rails'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.4', '>= 7.0.4.3'
gem 'sprockets-rails'
gem 'tzinfo-data'

# Authentication
gem 'devise', '~> 4.8'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml', '~> 2.1.0'

# Exceptions notifications
gem 'sentry-rails'
gem 'sentry-ruby'

group :development, :test do
  gem 'debug'
  gem 'dotenv-rails'
  gem 'pry'
  gem 'rspec-expectations'
  gem 'rspec-rails'
  gem 'rswag'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-lcov'
  gem 'simplecov-rcov'
  gem 'super_diff'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock', '>= 3.13.0'
end

