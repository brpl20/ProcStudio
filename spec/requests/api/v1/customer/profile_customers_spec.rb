# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/customer/profile_customers', type: :request do
  let!(:customer) { create(:profile_customer).customer }
  let(:profile_customer) { customer.profile_customer }
  let(:valid_headers) { { Authorization: "Bearer #{customer.jwt_token}", Accept: 'application/json' } }

  before { customer.update confirmed_at: 5.minutes.ago }

  describe 'GET /show' do
    it 'renders a successful response' do
      get api_v1_customer_profile_customer_url(profile_customer), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Jhones', last_name: 'Silva' } }

      it 'updates the requested draft_work' do
        patch api_v1_customer_profile_customer_url(profile_customer), params: { profile_customer: new_attributes }, headers: valid_headers, as: :json
        profile_customer.reload
        expect(profile_customer.name).to eq('Jhones')
        expect(profile_customer.last_name).to eq('Silva')
      end
    end
  end
end
