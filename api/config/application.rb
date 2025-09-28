# frozen_string_literal: true

require_relative 'boot'

# Instead of requiring "rails/all", require only what's needed for API
require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
require 'action_cable/engine'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Procstudio_api
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.api_only = true
    config.load_defaults 7.0
    config.i18n.default_locale = :'pt-BR'
    config.time_zone = 'Brasilia'
    config.active_record.default_timezone = :local

    config.action_mailer.default_url_options = { host: 'procstudio.com.br' }

    # Action Cable configuration
    config.action_cable.mount_path = '/cable'
    config.action_cable.url = 'ws://localhost:3000/cable'
    config.action_cable.allowed_request_origins = ['http://localhost:5173', 'http://localhost:3000']
    config.action_cable.disable_request_forgery_protection = true if Rails.env.development?

    config.autoload_paths << "#{config.root}/app/models/filters"
    config.autoload_paths << "#{config.root}/app/models/services"
    config.autoload_paths << "#{config.root}/lib/helpers"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.before_configuration do
      ENV['ZAPSIGN_BASE_URL'] = 'https://sandbox.api.zapsign.com.br/api'
      ENV['ZAPSIGN_API_TOKEN'] = 'fake-api-token'
    end
  end
end
