FactoryBot.define do
  factory :contact_phone do
    contactable { nil }
    number { "MyString" }
    phone_type { "MyString" }
    is_primary { false }
    is_whatsapp { false }
  end
end
