# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    procedure { 'administrative' }
    subject { 'criminal' }
    number { 1 }
    folder { Faker::Lorem.word }
    initial_atendee { 'MyString' }
    note { Faker::Lorem.word }
    extra_pending_document { 'MyString' }
  end
end
