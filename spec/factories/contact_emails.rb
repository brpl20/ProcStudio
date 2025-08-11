FactoryBot.define do
  factory :contact_email do
    contactable { nil }
    address { "MyString" }
    email_type { "MyString" }
    is_primary { false }
    is_verified { false }
  end
end
