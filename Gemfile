source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

gem "bootsnap", require: false
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"
gem 'sprockets-rails'
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-expectations"
  gem "rspec-rails"
  gem 'rswag'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "shoulda-matchers"
  gem "simplecov" 
  gem "simplecov-lcov" 
  gem "simplecov-rcov"
  gem "super_diff"
  gem "vcr"
  gem "webmock", ">= 3.13.0"
end

