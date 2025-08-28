# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  address_type     :string           default("main")
#  addressable_type :string           not null
#  city             :string           not null
#  complement       :string
#  deleted_at       :datetime
#  neighborhood     :string
#  number           :string
#  state            :string           not null
#  street           :string           not null
#  zip_code         :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :bigint           not null
#
# Indexes
#
#  index_addresses_on_addressable     (addressable_type,addressable_id)
#  index_addresses_on_city_and_state  (city,state)
#  index_addresses_on_deleted_at      (deleted_at)
#  index_addresses_on_zip_code        (zip_code)
#
require 'rails_helper'

RSpec.describe Address, type: :model do
  context 'Attributes' do
    it {
      is_expected.to have_attributes(
        id: nil,
        description: nil,
        zip_code: nil,
        street: nil,
        number: nil,
        neighborhood: nil,
        city: nil,
        state: nil,
        created_at: nil,
        updated_at: nil
      )
    }
  end

  context 'Relations' do
    it { is_expected.to have_many(:admin_addresses).dependent(:destroy) }
    it { is_expected.to have_many(:profile_admins).through(:admin_addresses) }
  end

  context 'Validations' do
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:street) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
  end
end
