# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer::CustomerPolicy, type: :policy do
  let(:customer) { create(:customer) }

  subject { described_class }

  permissions :show? do
    it { is_expected.to permit(customer, customer) }
  end

  permissions :update? do
    it { is_expected.to permit(customer, customer) }
  end
end
