# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer::CustomerPolicy, type: :policy do
  let(:customer) { create(:customer) }

  subject { described_class }

  context 'when customer is not confirmed' do
    permissions :show? do
      it { is_expected.to_not permit(customer, customer) }
    end

    permissions :update? do
      it { is_expected.to_not permit(customer, customer) }
    end
  end

  context 'when customer is confirmed' do
    before { customer.update confirmed_at: 5.minutes.ago }

    permissions :show? do
      it { is_expected.to permit(customer, customer) }
    end

    permissions :update? do
      it { is_expected.to permit(customer, customer) }
    end
  end
end
