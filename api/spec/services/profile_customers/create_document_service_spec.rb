# frozen_string_literal: true

describe ProfileCustomers::CreateDocumentService do
  describe '.call' do
    let!(:profile_customer_one) { create(:profile_customer) }
    let!(:profile_customer_two) { create(:profile_customer) }
    let!(:profile_admin) { create(:profile_admin) }
    let!(:document) do
      create(:customer_file, profile_customer: profile_customer_one, file_description: 'simple_procuration')
    end

    before do
      allow(ProfileCustomers::SimpleProcurationService).to receive(:call)
    end

    context 'when profile_customer have documents' do
      it 'call create a document service' do
        described_class.call(profile_customer_one, profile_admin.admin)
        expect(ProfileCustomers::SimpleProcurationService).to have_received(:call).with(document.id, profile_admin.id)
      end
    end

    context 'when profile_customer do not have documents' do
      it 'do not calls create a document service' do
        described_class.call(profile_customer_two, profile_admin.admin)
        expect(ProfileCustomers::SimpleProcurationService).not_to have_received(:call).with(document.id,
                                                                                            profile_admin.id)
      end
    end
  end
end
