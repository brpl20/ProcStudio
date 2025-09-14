# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development, allow localhost connections
    if Rails.env.development?
      origins 'http://localhost:5173', 'http://localhost:3000'
    else
      # In production, replace with your actual frontend domain
      origins ENV.fetch('FRONTEND_URL', '*')
    end
    
    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             expose: ['Authorization', 'X-Total-Count', 'X-Page', 'X-Per-Page'],
             credentials: true
  end
end
