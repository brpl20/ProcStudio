# frozen_string_literal: true

# == Schema Information
#
# Table name: work_events
#
#  id          :bigint           not null, primary key
#  date        :datetime
#  deleted_at  :datetime
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  work_id     :bigint           not null
#
# Indexes
#
#  index_work_events_on_deleted_at  (deleted_at)
#  index_work_events_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_id => works.id)
#
require 'rails_helper'

RSpec.describe WorkEvent, type: :model do
  describe 'Attributes' do
    it do
      is_expected.to have_attributes(
        id: nil,
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

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:date) }
  end
end
