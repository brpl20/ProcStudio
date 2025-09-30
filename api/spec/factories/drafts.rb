# frozen_string_literal: true

# == Schema Information
#
# Table name: drafts
#
#  id             :bigint           not null, primary key
#  data           :json             not null
#  draftable_type :string           not null
#  expires_at     :datetime
#  form_type      :string           not null
#  status         :string           default("draft")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  customer_id    :bigint
#  draftable_id   :bigint
#  team_id        :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_drafts_new_records              (team_id,user_id,form_type,draftable_type) WHERE (draftable_id IS NULL)
#  index_drafts_on_customer_id           (customer_id)
#  index_drafts_on_draftable             (draftable_type,draftable_id)
#  index_drafts_on_expires_at            (expires_at)
#  index_drafts_on_status                (status)
#  index_drafts_on_team_id               (team_id)
#  index_drafts_on_user_id               (user_id)
#  index_drafts_unique_existing_records  (team_id,draftable_type,draftable_id,form_type) UNIQUE WHERE
#                                     (draftable_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :draft do
    association :draftable, factory: :work
    form_type { 'work_form' }
    data { { field1: 'value1', field2: 'value2', timestamp: Time.current.to_s } }
    status { 'draft' }
    expires_at { 30.days.from_now }
    user { nil }
    customer { nil }
    team { nil }

    trait :with_user do
      user
      team { user.team }
    end

    trait :with_customer do
      customer
      team { customer.teams.first || create(:team) }
    end

    trait :with_team do
      team
    end

    trait :recovered do
      status { 'recovered' }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.day.ago }
    end

    trait :no_expiration do
      expires_at { nil }
    end

    trait :complex_data do
      data do
        {
          personal_info: {
            name: Faker::Name.name,
            email: Faker::Internet.email,
            phone: Faker::PhoneNumber.phone_number
          },
          preferences: {
            notifications: true,
            theme: 'dark'
          },
          metadata: {
            created_at: Time.current.to_s,
            version: '1.0'
          }
        }
      end
    end
  end
end
