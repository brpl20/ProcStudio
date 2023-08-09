# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    description { 'MyString' }
    deadline { '2023-05-04' }
    status { 'MyString' }
    priority { 'MyString' }
    comment { 'MyString' }
  end
  trait :job_complete do
    profile_customer_id { create(:profile_customer).id }
    profile_admin_id { create(:profile_admin).id }
    work_id { create(:work).id }
  end
end
