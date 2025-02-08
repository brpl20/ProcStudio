# frozen_string_literal: true

describe ProfileCustomers::SimpleProcurationService do
  describe '.call' do
    let!(:profile_customer) { create(:profile_customer) }
    let!(:address_one) { create(:address) }
    let!(:address_two) { create(:address) }
    let!(:bank_account) { create(:bank_account) }
    let!(:email) { create(:email) }
    let!(:document) { create(:customer_file, profile_customer: profile_customer, file_description: 'simple_procuration') }
    let!(:profile_admin) { create(:profile_admin) }
    before do
      profile_customer.address_ids = [address_one.id]
      profile_customer.bank_account_ids = [bank_account.id]
      profile_customer.email_ids = [email.id]
      profile_admin.address_ids = [address_two.id]
      profile_admin.bank_account_ids = [bank_account.id]
      profile_admin.email_ids = [email.id]
    end

    it 'creates a document' do
      described_class.call(document.id, profile_admin.id)
      expect(document.file).to be_attached
    end
  end
end
