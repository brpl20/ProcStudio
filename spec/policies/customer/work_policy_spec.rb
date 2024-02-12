require 'rails_helper'

RSpec.describe Customer::WorkPolicy, type: :policy do
  let(:customer) { create(:profile_customer).customer }

  subject { described_class }

  describe 'when the customer has profile customer' do
    permissions :index? do
      it { is_expected.to permit(customer, nil) }
    end

    permissions :show? do
      let(:work) { create(:work, profile_customers: [customer.profile_customer]) }

      it { is_expected.to permit(customer, work) }
    end
  end
end
