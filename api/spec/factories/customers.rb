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
#  index_customers_on_confirmation_token    (confirmation_token) UNIQUE
#  index_customers_on_created_by_id         (created_by_id)
#  index_customers_on_deleted_at            (deleted_at)
#  index_customers_on_email_not_deleted     (email) WHERE (deleted_at IS NULL)
#  index_customers_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
FactoryBot.define do
  factory :customer do
    email { Faker::Internet.email }
    password { '123456' }
    password_confirmation { '123456' }

    after(:create) do |customer|
      token = JWT.encode(
        { customer_id: customer.id, exp: Time.now.advance(hours: 24).to_i },
        Rails.application.secret_key_base
      )
      customer.update(jwt_token: token)
    end

    trait :confirmed do
      confirmed_at { 5.minutes.ago }
    end
  end
end
