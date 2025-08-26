# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  jwt_token              :string
#  oab                    :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  status                 :string           default("active"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  team_id                :bigint           not null
#
# Indexes
#
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_jwt_token             (jwt_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_team_id               (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    oab { Faker::Number.number(digits: 6).to_s }
    status { 'active' }
    team

    after(:create) do |user|
      token = JWT.encode(
        { user_id: user.id, exp: Time.now.advance(hours: 24).to_i },
        Rails.application.secret_key_base
      )
      user.update(jwt_token: token)
    end

    trait :with_profile do
      after(:create) do |user|
        create(:user_profile, user: user)
      end
    end

    trait :inactive do
      status { 'inactive' }
    end

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
