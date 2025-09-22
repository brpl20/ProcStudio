# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id            :bigint           not null, primary key
#  avatar_s3_key :string
#  birth         :date
#  civil_status  :string
#  cpf           :string
#  deleted_at    :datetime
#  gender        :string
#  last_name     :string
#  mother_name   :string
#  name          :string
#  nationality   :string
#  oab           :string
#  origin        :string
#  rg            :string
#  role          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  office_id     :bigint
#  user_id       :bigint           not null
#
# Indexes
#
#  index_user_profiles_on_avatar_s3_key  (avatar_s3_key)
#  index_user_profiles_on_deleted_at     (deleted_at)
#  index_user_profiles_on_office_id      (office_id)
#  index_user_profiles_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :user_profile do
    user
    name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    cpf { Faker::Number.number(digits: 11).to_s }
    rg { Faker::Number.number(digits: 9).to_s }
    birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    gender { ['male', 'female'].sample }
    civil_status { ['single', 'married', 'divorced', 'widowed'].sample }
    nationality { 'brazilian' }
    mother_name { "#{Faker::Name.female_first_name} #{Faker::Name.last_name}" }
    oab { Faker::Number.number(digits: 6).to_s }
    role { ['admin', 'lawyer', 'secretary', 'intern'].sample }
    status { 'active' }

    trait :admin do
      role { 'admin' }
    end

    trait :lawyer do
      role { 'lawyer' }
    end

    trait :secretary do
      role { 'secretary' }
    end

    trait :intern do
      role { 'intern' }
    end
  end
end
