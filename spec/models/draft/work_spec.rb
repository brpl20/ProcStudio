# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Draft::Work, type: :model do
  it do
    is_expected.to have_attributes(
      id: nil,
      name: nil,
      work_id: nil,
      created_at: nil,
      updated_at: nil
    )
  end
end

context 'On record' do
  subject(:work) { build(:draft_work) }

  describe 'Associations' do
    it { is_expected.to belong_to(:work) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it do
      subject.work = create(:work)
      is_expected.to validate_uniqueness_of(:name).case_insensitive
    end
  end
end
