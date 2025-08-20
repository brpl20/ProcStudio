# frozen_string_literal: true

# == Schema Information
#
# Table name: pending_documents
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  description         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint
#  work_id             :bigint           not null
#
# Indexes
#
#  index_pending_documents_on_deleted_at           (deleted_at)
#  index_pending_documents_on_profile_customer_id  (profile_customer_id)
#  index_pending_documents_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (work_id => works.id)
#
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
