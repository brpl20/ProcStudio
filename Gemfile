# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'bootsnap', require: false
gem 'bootstrap', '~> 5.2.2'
gem 'cocoon'
gem 'devise'
gem 'font-awesome-rails'
gem 'i18n'
gem 'importmap-rails'
gem 'jbuilder'
gem 'jquery-datatables-rails', '~> 3.4.0'
gem 'jquery-rails'
gem 'jquery-validation-rails'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.4', '>= 7.0.4.2'
gem 'rubocop', '~> 1.48', require: false
gem 'sass-rails', '~> 6.0'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :staging do
  gem 'database_cleaner'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'mina', '0.3.8'
  gem 'rspec-rails', '~> 6.0.0'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console'
end

group :staging do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
