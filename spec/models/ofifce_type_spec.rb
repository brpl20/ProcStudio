# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfficeType, type: :model do
  describe 'Attributes' do
    it {
      is_expected.to have_attributes(
        id: nil,
        description: nil,
        created_at: nil,
        updated_at: nil
      )
    }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:description) }
  end
end
