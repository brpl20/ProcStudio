# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    procedure { Faker::Lorem.word }
    subject { Faker::Lorem.word }
    action { Faker::Lorem.word }
    number { 1 }
    rate_percentage { Faker::Lorem.word }
    rate_percentage_exfield { 'MyString' }
    rate_fixed { 'MyString' }
    rate_parceled_exfield { 'MyString' }
    folder { Faker::Lorem.word }
    initial_atendee { 'MyString' }
    note { Faker::Lorem.word }
    checklist { 'MyString' }
    pending_document { 'MyString' }
    office
  end
end
