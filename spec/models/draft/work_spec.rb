# frozen_string_literal: true

# == Schema Information
#
# Table name: draft_works
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  work_id    :bigint           not null
#
# Indexes
#
#  index_draft_works_on_deleted_at  (deleted_at)
#  index_draft_works_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_id => works.id)
#
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
end
