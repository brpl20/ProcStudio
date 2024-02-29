# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PendingDocument, type: :model do
  it do
    is_expected.to have_attributes(
      id: nil,
      description: nil,
      work_id: nil,
      created_at: nil,
      updated_at: nil,
      profile_customer_id: nil
    )
  end

  context 'Associations' do
    subject { build(:pending_document) }
    it { is_expected.to belong_to(:work) }
    it { is_expected.to belong_to(:profile_customer) }
  end
end
