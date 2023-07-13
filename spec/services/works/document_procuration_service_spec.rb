# frozen_string_literal: true

describe Works::DocumentProcurationService do
  describe '.call' do
    let!(:profile_customer) { create(:profile_customer) }
    let!(:address) { create(:address) }
    let!(:bank_account) { create(:bank_account) }
    let!(:email) { create(:email) }
    let!(:work_one) { create(:work) }
    let!(:document) { create(:document, work: work_one, document_type: 'procuration') }
    before do
      work_one.profile_customer_ids = [profile_customer.id]
      profile_customer.address_ids = [address.id]
      profile_customer.bank_account_ids = [bank_account.id]
      profile_customer.email_ids = [email.id]
    end

    it 'creates a document' do
      described_class.call(document.id)
      expect(document.document_docx).to be_attached
    end
  end
end
