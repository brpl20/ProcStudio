# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  jwt_token              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  status                 :string           default("active"), not null
#  unconfirmed_email      :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  created_by_id          :bigint
#
# Indexes
#
#  index_customers_on_confirmation_token       (confirmation_token) UNIQUE
#  index_customers_on_created_by_id            (created_by_id)
#  index_customers_on_deleted_at               (deleted_at)
#  index_customers_on_email_where_not_deleted  (email) UNIQUE WHERE (deleted_at IS NULL)
#  index_customers_on_reset_password_token     (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
class CustomerSerializer
  include JSONAPI::Serializer

  attributes :access_email, :created_by_id, :confirmed_at, :profile_customer_id, :status, :created_at

  attribute :confirmed, &:confirmed?

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  # Include teams associated with the customer
  has_many :teams, serializer: TeamSerializer

  # Include profile if exists
  has_one :profile_customer, serializer: ProfileCustomerSerializer
end
