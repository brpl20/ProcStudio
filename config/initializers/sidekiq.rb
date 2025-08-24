# frozen_string_literal: true

# Configure Sidekiq client and server
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }

  # Configure job retry
  config.default_retry_jitter = 0.15

  # Log to Rails logger
  config.logger = Rails.logger

  # Handle failures
  config.death_handlers << lambda do |job, ex|
    Rails.logger.error "[Sidekiq] Job #{job['class']} died: #{ex.message}"
  end

  # Load scheduled jobs for sidekiq-cron
  schedule_file = Rails.root.join('config/sidekiq_cron.yml')
  if File.exist?(schedule_file) && Sidekiq.server?
    require 'sidekiq-cron'

    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    Rails.logger.info "[Sidekiq-Cron] Loaded scheduled jobs from #{schedule_file}"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

# Configure Active Job to use Sidekiq in production/staging
Rails.application.config.active_job.queue_adapter = :sidekiq if Rails.env.production? || Rails.env.staging?
