source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'aws-sdk-s3', '~> 1.166'
gem 'bootsnap', '~> 1.18.4', require: false
gem 'clamby', '~> 1.6'
gem 'cssbundling-rails'
gem 'factory_bot_rails', '>= 6.4.3'
gem 'faker'
gem 'govuk_notify_rails', '~> 3.0.0'
gem 'grover'
gem 'httparty'
gem 'jsbundling-rails'
# TODO: Remove ref before merge
gem 'laa_crime_forms_common', '~> 0.2.2', github: 'ministryofjustice/laa-crime-forms-common',
    ref: '109327c'
gem 'laa_multi_step_forms', path: './gems/laa_multi_step_forms'
gem 'lograge'
gem 'logstasher', '~> 2.1'
gem 'logstash-event'
gem 'marcel'
gem 'oauth2', '~> 2.0'
gem 'ostruct'
gem 'pagy', '~> 9.0.9'
gem 'pg', '~> 1.5'
gem 'prometheus_exporter'
gem 'propshaft'
gem 'puma', '~> 6.4.3'
gem 'rails', '~> 7.2.1'
gem 'redis'
gem 'sentry-rails', '~> 5.20.1'
gem 'sentry-ruby', '~> 5.20.1'
gem 'sidekiq', '~> 7.3'
gem 'sidekiq_alive', '~> 2.4'
gem 'sidekiq-cron', '~> 1.12.0'
gem 'solid_cache', '~> 1.0'
gem 'table_print'
gem 'turbo-rails', '~> 2.0.10'
gem 'tzinfo-data'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv-rails'
  gem 'erb_lint', '>= 0.6.0', require: false
  gem 'overcommit'
  gem 'pry'
  gem 'rspec-expectations'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails', '~> 7.0.1'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'axe-core-rspec'
  gem 'capybara'
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
  gem 'simplecov-rcov'
  gem 'super_diff'
  gem 'webmock', '~> 3.24'
end
