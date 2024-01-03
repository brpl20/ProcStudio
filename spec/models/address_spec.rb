# frozen_string_literal: true

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
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:neighborhood) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
  end
end
