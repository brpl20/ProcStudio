# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer::ProfileCustomerPolicy, type: :policy do
  let(:customer) { create(:profile_customer).customer }

  subject { described_class }

  describe 'when customer is not confirmed' do
    permissions :show? do
      it { is_expected.to_not permit(customer, customer.profile_customer) }
    end

    permissions :update? do
      it { is_expected.to_not permit(customer, customer.profile_customer) }
    end
  end

  describe 'when customer is confirmed' do
    before { customer.update confirmed_at: 5.minutes.ago }

    permissions :show? do
      it { is_expected.to permit(customer, customer.profile_customer) }
    end

    permissions :update? do
      it { is_expected.to permit(customer, customer.profile_customer) }
    end
  end
end
