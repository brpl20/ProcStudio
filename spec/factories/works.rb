# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    procedure { 'administrative' }
    subject { 'criminal' }
    number { 1 }
    folder { Faker::Lorem.word }
    initial_atendee { 6 }
    note { Faker::Lorem.word }
    extra_pending_document { 'MyString' }
    physical_lawyer { 1 }
    responsible_lawyer { 2 }
    partner_lawyer { 3 }
    intern { 4 }
    bachelor { 5 }
  end
end
