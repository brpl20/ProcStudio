FactoryBot.define do
  factory :contact_bank_account do
    contactable { nil }
    bank_name { "MyString" }
    bank_code { "MyString" }
    agency { "MyString" }
    account_number { "MyString" }
    account_type { "MyString" }
    pix_key { "MyString" }
    is_primary { false }
  end
end
