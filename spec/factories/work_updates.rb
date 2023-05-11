# frozen_string_literal: true

FactoryBot.define do
  factory :work_update do
    description { 'MyString' }
    show_to { 'MyString' }
    work { nil }
  end
end
