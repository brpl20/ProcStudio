# frozen_string_literal: true

# == Schema Information
#
# Table name: user_invitations
#
#  id            :bigint           not null, primary key
#  accepted_at   :datetime
#  deleted_at    :datetime
#  email         :string           not null
#  expires_at    :datetime         not null
#  metadata      :jsonb
#  status        :string           default("pending"), not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :bigint           not null
#  team_id       :bigint           not null
#
# Indexes
#
#  index_user_invitations_on_deleted_at                    (deleted_at)
#  index_user_invitations_on_email                         (email)
#  index_user_invitations_on_email_and_team_id_and_status  (email,team_id,status)
#  index_user_invitations_on_invited_by_id                 (invited_by_id)
#  index_user_invitations_on_status                        (status)
#  index_user_invitations_on_team_id                       (team_id)
#  index_user_invitations_on_token                         (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
FactoryBot.define do
  factory :user_invitation do
    sequence(:email) { |n| "invitee#{n}@example.com" }
    status { 'pending' }
    expires_at { 7.days.from_now }
    metadata { { suggested_role: 'lawyer' } }

    association :invited_by, factory: :user
    association :team

    trait :accepted do
      status { 'accepted' }
      accepted_at { Time.current }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.day.ago }
    end

    trait :pending do
      status { 'pending' }
      expires_at { 7.days.from_now }
    end

    trait :expiring_soon do
      expires_at { 1.day.from_now }
    end
  end
end
