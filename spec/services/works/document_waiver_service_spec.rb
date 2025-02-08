# frozen_string_literal: true

describe Works::DocumentWaiverService do
  describe '.call' do
    let!(:profile_customer) { create(:profile_customer) }
    let!(:address_one) { create(:address) }
    let!(:address_two) { create(:address) }
    let!(:bank_account) { create(:bank_account) }
    let!(:email) { create(:email) }
    let!(:work_one) { create(:work) }
    let!(:document) { create(:document, work: work_one, document_type: 'waiver') }
    let!(:profile_admin) { create(:profile_admin) }
    before do
      work_one.profile_customer_ids = [profile_customer.id]
      work_one.profile_admin_ids = [profile_admin.id]
      profile_customer.address_ids = [address_one.id]
      profile_customer.bank_account_ids = [bank_account.id]
      profile_customer.email_ids = [email.id]
      profile_admin.address_ids = [address_two.id]
      profile_admin.bank_account_ids = [bank_account.id]
      profile_admin.email_ids = [email.id]
    end

    it 'creates a document' do
      described_class.call(document.id)
      expect(document.file).to be_attached
    end
  end
end
