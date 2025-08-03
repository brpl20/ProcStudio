# frozen_string_literal: true

FactoryBot.define do
  factory :payment_transaction do
    association :subscription
    amount { 99.99 }
    currency { 'BRL' }
    status { 'pending' }
    payment_method { 'credit_card' }
    sequence(:transaction_id) { |n| "txn_#{n}" }
    payment_data do
      {
        'gateway' => 'stripe',
        'gateway_transaction_id' => "pi_#{SecureRandom.hex(12)}",
        'payment_method_details' => {
          'type' => 'card',
          'card' => {
            'brand' => 'visa',
            'last4' => '4242'
          }
        }
      }
    end
    
    trait :processing do
      status { 'processing' }
    end
    
    trait :completed do
      status { 'completed' }
      processed_at { Time.current }
    end
    
    trait :failed do
      status { 'failed' }
      processed_at { Time.current }
      payment_data do
        {
          'gateway' => 'stripe',
          'error_code' => 'card_declined',
          'error_message' => 'Your card was declined.'
        }
      end
    end
    
    trait :cancelled do
      status { 'cancelled' }
    end
    
    trait :refunded do
      status { 'refunded' }
      processed_at { Time.current }
    end
    
    trait :pix do
      payment_method { 'pix' }
      payment_data do
        {
          'gateway' => 'pagarme',
          'pix_code' => '00020126580014br.gov.bcb.pix'
        }
      end
    end
    
    trait :boleto do
      payment_method { 'boleto' }
      payment_data do
        {
          'gateway' => 'pagarme',
          'boleto_url' => 'https://example.com/boleto/123'
        }
      end
    end
  end
end