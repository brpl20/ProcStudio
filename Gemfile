# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'acts_as_paranoid'
gem 'ancestry', '~> 4.3' # For hierarchical tree structure of procedures
gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'devise'
gem 'docx'
gem 'down'
gem 'httparty'
gem 'i18n'
gem 'jsonapi-serializer'
gem 'jwt'
gem 'libreconv', '~> 0.9.5'
gem 'mailjet'
gem 'paper_trail'
gem 'pg'
gem 'prawn'
gem 'puma', '~> 6.0'
gem 'pundit'
gem 'rack-cors'
gem 'rails', '~> 8.0.0'
gem 'rubocop', '~> 1.50', require: false
gem 'rubocop-performance', '~> 1.17', require: false
gem 'rubocop-rails', '~> 2.19', require: false
gem 'rubocop-rspec', '~> 2.20', require: false
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Background jobs
gem 'redis', '~> 5.0'
gem 'sidekiq', '~> 7.2'
gem 'sidekiq-cron', '~> 2.0'

group :development, :test, :staging do
  gem 'claude-on-rails'
  gem 'faker'
  gem 'mina', '0.3.8'
  gem 'pry-byebug'
  gem 'webmock'
end

group :development, :test do
  gem 'annotaterb'
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'bundle-audit', require: false
  gem 'database_cleaner'
  gem 'debug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 6.0.0'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.22.0'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

gem 'extensobr'
