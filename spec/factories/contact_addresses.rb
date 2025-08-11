FactoryBot.define do
  factory :contact_address do
    contactable { nil }
    street { "MyString" }
    number { "MyString" }
    complement { "MyString" }
    neighborhood { "MyString" }
    city { "MyString" }
    state { "MyString" }
    zip_code { "MyString" }
    country { "MyString" }
    is_primary { false }
  end
end
