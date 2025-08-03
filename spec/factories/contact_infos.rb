# frozen_string_literal: true

FactoryBot.define do
  factory :contact_info do
    association :contactable, factory: :individual_entity
    contact_type { 'email' }
    is_primary { false }
    
    trait :address do
      contact_type { 'address' }
      contact_data do
        {
          'street' => Faker::Address.street_name,
          'number' => Faker::Address.building_number,
          'complement' => Faker::Address.secondary_address,
          'neighborhood' => Faker::Address.community,
          'city' => Faker::Address.city,
          'state' => Faker::Address.state_abbr,
          'zipcode' => Faker::Address.zip_code.gsub('-', ''),
          'country' => 'Brasil'
        }
      end
    end
    
    trait :email do
      contact_type { 'email' }
      contact_data do
        {
          'email' => Faker::Internet.email,
          'type' => %w[personal work other].sample
        }
      end
    end
    
    trait :phone do
      contact_type { 'phone' }
      contact_data do
        {
          'phone_number' => Faker::PhoneNumber.cell_phone.gsub(/\D/, ''),
          'type' => %w[mobile home work].sample,
          'country_code' => '+55'
        }
      end
    end
    
    trait :bank_account do
      contact_type { 'bank_account' }
      contact_data do
        {
          'bank_name' => Faker::Bank.name,
          'account_type' => %w[checking savings].sample,
          'agency' => Faker::Number.number(digits: 4),
          'account_number' => Faker::Number.number(digits: 8),
          'account_digit' => Faker::Number.digit,
          'operation' => Faker::Number.number(digits: 3)
        }
      end
    end
    
    trait :primary do
      is_primary { true }
    end
    
    trait :for_legal_entity do
      association :contactable, factory: :legal_entity
    end
    
    trait :for_admin do
      association :contactable, factory: :admin
    end
  end
end