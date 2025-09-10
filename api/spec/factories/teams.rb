# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string           not null
#  settings   :jsonb
#  subdomain  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_deleted_at  (deleted_at)
#  index_teams_on_subdomain   (subdomain) UNIQUE
#
FactoryBot.define do
  factory :team do
    name { Faker::Company.name }
    subdomain { Faker::Internet.slug(words: name, glue: '-').downcase }
    settings { {} }

    trait :with_users do
      transient do
        users_count { 3 }
      end

      after(:create) do |team, evaluator|
        create_list(:user, evaluator.users_count, team: team)
      end
    end

    trait :with_customers do
      transient do
        customers_count { 5 }
      end

      after(:create) do |team, evaluator|
        customers = create_list(:customer, evaluator.customers_count)
        customers.each do |customer|
          create(:team_customer, team: team, customer: customer)
        end
      end
    end
  end
end
