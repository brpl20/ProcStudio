# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Represent, type: :model do
  context 'Attributes' do
    it {
      is_expected.to have_attributes(
        id: nil,
        profile_customer_id: nil,
        created_at: nil,
        updated_at: nil,
        profile_admin_id: nil
      )
    }
  end

  context 'Relations' do
    it { is_expected.to belong_to(:profile_customer) }
    it { is_expected.to belong_to(:profile_admin) }
  end
end
