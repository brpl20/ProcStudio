# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'Attributes' do
    it {
      is_expected.to have_attributes(
        id: nil,
        description: nil,
        deadline: nil,
        status: nil,
        priority: nil,
        comment: nil,
        created_at: nil,
        updated_at: nil,
        profile_admin_id: nil,
        work_id: nil,
        profile_customer_id: nil,
        created_by_id: nil,
        deleted_at: nil
      )
    }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:work).optional }
    it { is_expected.to belong_to(:profile_customer).optional }
    it { is_expected.to belong_to(:profile_admin) }
  end
end
