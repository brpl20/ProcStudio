# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkEvent, type: :model do
  describe 'Attributes' do
    it do
      is_expected.to have_attributes(
        id: nil,
        status: nil,
        description: nil,
        date: nil,
        work_id: nil,
        created_at: nil,
        updated_at: nil
      )
    end
  end

  describe 'Associations' do
    subject(:work_event) { build(:work_event) }

    it { is_expected.to belong_to(:work) }
  end

  describe 'Enums' do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(
          in_progress: 'in_progress',
          paused: 'paused',
          completed: 'completed'
        ).backed_by_column_of_type(:string)
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:date) }
  end
end
