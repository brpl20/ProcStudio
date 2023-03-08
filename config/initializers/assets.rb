# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'webfonts', 'plugin')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[
  jquery.min.js
  bootstrap.bundle.min.js
  jquery.easing.min.js
  sb-admin-2.js
  steps.js
  backoffice.js
]

Rails.application.config.assets.precompile += %w[
  backoffice.css
  fontawesome.all.min.css
  sb-admin-2.css
  devise_custom.css
  steps.css
]
