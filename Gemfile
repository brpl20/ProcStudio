# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'aws-sdk-s3'
gem 'bootsnap', require: false
gem 'devise'
gem 'docx'
gem 'i18n'
gem 'importmap-rails'
gem 'jbuilder'
gem 'jsonapi-serializer'
gem 'jwt'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rack-cors'
gem 'rails', '~> 7.0.4', '>= 7.0.4.2'
gem 'rubocop', '~> 1.48', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :staging do
  gem 'database_cleaner'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'mina', '0.3.8'
  gem 'rspec-rails', '~> 6.0.0'
end
