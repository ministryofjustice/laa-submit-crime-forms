source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'aws-sdk-s3', '~> 1.199'
gem 'bootsnap', '~> 1.18.6', require: false
gem 'clamby', '~> 1.6'
gem 'cssbundling-rails'
gem 'devise', '~> 4.8'
gem 'factory_bot_rails', '>= 6.4.3'
gem 'faker'
gem 'govuk-components', '5.11.1'
gem 'govuk_design_system_formbuilder', '>= 5.4', '< 5.12'
gem 'govuk_notify_rails', '~> 3.0.0'
gem 'grover'
gem 'httparty'
gem 'jsbundling-rails'
gem 'laa_crime_forms_common', '~> 0.12.3', github: 'ministryofjustice/laa-crime-forms-common'
gem 'lograge'
gem 'logstasher', '~> 2.1'
gem 'logstash-event'
gem 'marcel'
gem 'oauth2', '~> 2.0'
gem 'omniauth-entra-id'
gem 'omniauth-rails_csrf_protection', '~> 1.0.1'
gem 'ostruct'
gem 'pagy', '~> 9.4.0'
gem 'pg', '~> 1.6'
gem 'prometheus_exporter'
gem 'propshaft'
gem 'puma', '~> 7.0.4'
gem 'rails', '8.0.3'
gem 'redis'
gem 'rexml'
gem 'sentry-rails', '~> 5.27.1'
gem 'sentry-ruby', '~> 5.27.0'
gem 'sidekiq', '~> 8.0'
gem 'sidekiq_alive', '~> 2.4'
gem 'sidekiq-cron'
gem 'solid_cache', '~> 1.0'
gem 'table_print'
gem 'turbo-rails', '~> 2.0.17'
gem 'tzinfo-data'
gem 'uk_postcode'
gem 'with_advisory_lock'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv-rails'
  gem 'erb_lint', '>= 0.6.0', require: false
  gem 'flatware-rspec', require: false
  gem 'overcommit'
  gem 'pdf-reader'
  gem 'pry'
  gem 'rspec-expectations'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails', '~> 8.0.2'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'axe-core-rspec'
  gem 'capybara'
  gem 'capybara-lockstep'
  gem 'capybara-selenium'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rubocop', '>= 1.65.1', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', '>= 2.25.1', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'simplecov-rcov'
  gem 'super_diff'
  gem 'webmock', '~> 3.25'
end

gem 'name_of_person', '~> 1.1'
