source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'bootsnap', require: false
gem 'dartsass-rails', '~> 0.5.0'
gem 'importmap-rails'
gem 'kaminari'
gem 'laa_multi_step_forms', path: './gems/laa_multi_step_forms'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.3'
gem 'rails', '~> 7.0.6'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sprockets-rails'
gem 'tzinfo-data'

# required as can't specify github in gemspe for laa_multi_step_form
gem 'hmcts_common_platform', github: 'ministryofjustice/hmcts_common_platform', tag: 'v0.2.0'

group :development, :test do
  gem 'debug'
  gem 'dotenv-rails'
  gem 'pry'
  gem 'rspec-expectations'
  gem 'rspec-rails'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov'
  gem 'simplecov-lcov'
  gem 'simplecov-rcov'
  gem 'super_diff'
end
