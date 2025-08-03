# frozen_string_literal: true

FactoryBot.define do
  factory :individual_entity do
    name { Faker::Name.name }
    sequence(:cpf) { |n| "#{n.to_s.rjust(11, '0')}" }
    gender { %w[male female other].sample }
    civil_status { %w[single married divorced widowed].sample }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 80) }
    nationality { 'Brasileira' }
    profession { Faker::Job.title }
    
    trait :male do
      gender { 'male' }
      name { Faker::Name.male_first_name + ' ' + Faker::Name.last_name }
    end
    
    trait :female do
      gender { 'female' }
      name { Faker::Name.female_first_name + ' ' + Faker::Name.last_name }
    end
    
    trait :married do
      civil_status { 'married' }
    end
    
    trait :single do
      civil_status { 'single' }
    end
    
    trait :with_contact_info do
      after(:create) do |entity|
        create(:contact_info, :address, contactable: entity, is_primary: true)
        create(:contact_info, :email, contactable: entity, is_primary: true)
        create(:contact_info, :phone, contactable: entity, is_primary: true)
      end
    end
  end
end