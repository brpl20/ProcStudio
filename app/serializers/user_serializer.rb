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
class UserSerializer
  include JSONAPI::Serializer

  attributes :access_email, :status

  has_one :user_profile, serializer: UserProfileSerializer

  attribute :deleted do |object|
    object.deleted_at.present?
  end
end
