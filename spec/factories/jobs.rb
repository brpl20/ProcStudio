# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    description { 'MyString' }
    deadline { '2023-05-04' }
    status { 'MyString' }
    priority { 'MyString' }
    comment { 'MyString' }
  end
end
