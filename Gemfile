source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'aws-sdk-s3', '~> 1.143'
gem 'bootsnap', '~> 1.18.3', require: false
gem 'clamby', '~> 1.6'
gem 'dartsass-rails', '~> 0.5.0'
gem 'factory_bot_rails', '>= 6.4.3'
gem 'govuk_notify_rails', '~> 2.2.0'
gem 'httparty'
gem 'importmap-rails'
gem 'laa_multi_step_forms', path: './gems/laa_multi_step_forms'
gem 'logstasher', '~> 2.1'
gem 'oauth2', '~> 2.0'
gem 'pagy', '~> 7.0.6'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.4'
gem 'rails', '~> 7.1.3'
gem 'sentry-rails', '~> 5.16.1'
gem 'sentry-ruby', '~> 5.16.1'
gem 'sidekiq', '~> 7.2'
gem 'sidekiq_alive', '~> 2.4'
gem 'sidekiq-cron', '~> 1.12.0'
gem 'sprockets-rails'
gem 'turbo-rails', '~> 2.0.4'
gem 'tzinfo-data'

# required as can't specify github in gemspe for laa_multi_step_form
gem 'hmcts_common_platform', github: 'ministryofjustice/hmcts_common_platform', tag: 'v0.2.0'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv-rails'
  gem 'erb_lint', require: false
  gem 'overcommit'
  gem 'pry'
  gem 'rspec-expectations'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails', '~> 6.1.1'
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
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'super_diff'
  gem 'webmock', '~> 3.23'
end
