# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer::WorkPolicy, type: :policy do
  let(:customer) { create(:profile_customer).customer }

  subject { described_class }

  describe 'when the customer has profile customer' do
    context 'when customer is not confirmed' do
      permissions :index? do
        it { is_expected.to_not permit(customer, nil) }
      end

      permissions :show? do
        let(:work) { create(:work, profile_customers: [customer.profile_customer]) }

        it { is_expected.to_not permit(customer, work) }
      end
    end

    context 'when customer is confirmed' do
      before { customer.update confirmed_at: 5.minutes.ago }

      permissions :index? do
        it { is_expected.to permit(customer, nil) }
      end

      permissions :show? do
        let(:work) { create(:work, profile_customers: [customer.profile_customer]) }

        it { is_expected.to permit(customer, work) }
      end
    end
  end
end
