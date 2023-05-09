# frozen_string_literal: true

FactoryBot.define do
  factory :job_work do
    job { nil }
    work { nil }
    profile_admin { nil }
    profile_customer { nil }
  end
end
