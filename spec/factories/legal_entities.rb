# frozen_string_literal: true

FactoryBot.define do
  factory :legal_entity do
    name { Faker::Company.name }
    sequence(:cnpj) { |n| "#{n.to_s.rjust(14, '0')}" }
    entity_type { %w[law_firm company office].sample }
    foundation_date { Faker::Date.between(from: 20.years.ago, to: 1.year.ago) }
    association :legal_representative, factory: :individual_entity
    
    trait :law_firm do
      entity_type { 'law_firm' }
      name { "#{Faker::Name.last_name} Advogados Associados" }
    end
    
    trait :company do
      entity_type { 'company' }
      name { "#{Faker::Company.name} Ltda" }
    end
    
    trait :office do
      entity_type { 'office' }
      name { "Escritório #{Faker::Name.last_name}" }
    end
    
    trait :with_contact_info do
      after(:create) do |entity|
        create(:contact_info, :address, contactable: entity, is_primary: true)
        create(:contact_info, :email, contactable: entity, is_primary: true)
        create(:contact_info, :phone, contactable: entity, is_primary: true)
        create(:contact_info, :bank_account, contactable: entity, is_primary: true)
      end
    end
  end
end