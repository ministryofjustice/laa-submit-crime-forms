source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem "aws-sdk-s3", '~> 1.213'
gem 'bootsnap', '~> 1.21.1', require: false
gem 'clamby', '~> 1.6'
gem 'cssbundling-rails'
gem 'devise', '~> 5.0'
gem 'factory_bot_rails', '>= 6.4.3'
gem 'faker'
gem 'govuk-components', '5.13.1'
gem 'govuk_design_system_formbuilder', '>= 5.4', '< 5.14'
gem 'govuk_notify_rails', '~> 3.0.0'
gem 'grover'
gem "httparty", '>= 0.24.0'
gem 'jsbundling-rails'
gem 'laa_crime_forms_common', '~> 0.12.9', github: 'ministryofjustice/laa-crime-forms-common'
gem 'lograge'
gem 'logstasher', '~> 3.0'
gem 'logstash-event'
gem 'marcel'
gem 'oauth2', '~> 2.0'
gem 'omniauth-entra-id'
gem 'omniauth-rails_csrf_protection', '~> 2.0.1'
gem 'ostruct'
gem 'pagy', '~> 9.4.0'
gem 'pg', '~> 1.6'
gem 'prometheus_exporter'
gem 'propshaft'
gem 'puma', '~> 7.2.0'
gem 'rails', '8.1.2'
gem 'redis'
gem 'rexml'
gem 'sentry-rails', '~> 6.3.0'
gem 'sentry-ruby', '~> 6.3.0'
gem 'sidekiq', '~> 8.0'
gem 'sidekiq_alive', '~> 2.4'
gem 'sidekiq-cron'
# Pin connection_pool to avoid bumping connection pool inadvertently to 3~ since this will break with our version of rails/sidekiq
# See: https://github.com/rails/rails/issues/56461
gem "connection_pool", "~> 3.0"
gem 'solid_cache', '~> 1.0'
gem 'table_print'
gem 'turbo-rails', '~> 2.0.22'
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
  gem 'webmock', '~> 3.26'
end

gem 'name_of_person', '~> 1.1'
