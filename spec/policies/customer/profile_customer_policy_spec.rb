# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer::ProfileCustomerPolicy, type: :policy do
  let(:customer) { create(:profile_customer).customer }

  subject { described_class }

  permissions :show? do
    it { is_expected.to permit(customer, customer.profile_customer) }
  end

  permissions :update? do
    it { is_expected.to permit(customer, customer.profile_customer) }
  end
end
