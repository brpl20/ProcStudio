FactoryBot.define do
  factory :system_setting do
    key { "MyString" }
    value { "9.99" }
    year { 1 }
    description { "MyText" }
    active { false }
  end
end
