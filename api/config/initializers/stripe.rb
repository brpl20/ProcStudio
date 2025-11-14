# frozen_string_literal: true

Stripe.api_key = ENV['STRIPE_SECRET_KEY']
Stripe.api_version = '2024-11-20.acacia' # Use latest API version

Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key: ENV['STRIPE_SECRET_KEY'],
  webhook_secret: ENV['STRIPE_WEBHOOK_SECRET'],
  price_pro_monthly: ENV['STRIPE_PRICE_PRO_MONTHLY'],
  price_extra_user: ENV['STRIPE_PRICE_EXTRA_USER']
}
