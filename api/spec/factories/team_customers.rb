# frozen_string_literal: true

# == Schema Information
#
# Table name: team_customers
#
#  id             :bigint           not null, primary key
#  customer_email :string           not null
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  customer_id    :bigint           not null
#  team_id        :bigint           not null
#
# Indexes
#
#  index_team_customers_on_customer_id                 (customer_id)
#  index_team_customers_on_deleted_at                  (deleted_at)
#  index_team_customers_on_team_and_customer           (team_id,customer_id) UNIQUE
#  index_team_customers_on_team_id                     (team_id)
#  index_team_customers_on_team_id_and_customer_email  (team_id,customer_email) UNIQUE
#  index_team_customers_on_team_id_and_customer_id     (team_id,customer_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (team_id => teams.id)
#
FactoryBot.define do
  factory :team_customer do
    team
    customer

    trait :with_profile do
      after(:create) do |team_customer|
        create(:profile_customer, customer: team_customer.customer) unless team_customer.customer.profile_customer
      end
    end
  end
end
