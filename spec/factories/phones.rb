# frozen_string_literal: true

# == Schema Information
#
# Table name: phones
#
#  id             :bigint           not null, primary key
#  deleted_at     :datetime
#  phone_number   :string
#  phoneable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  phoneable_id   :bigint
#
# Indexes
#
#  index_phones_on_deleted_at  (deleted_at)
#  index_phones_on_phoneable   (phoneable_type,phoneable_id)
#
FactoryBot.define do
  factory :phone do
    phone_number { Faker::PhoneNumber.cell_phone }
  end
end
