# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/customer/customers', type: :request do
  let!(:customer) { create(:customer) }
  let(:valid_headers) { { Authorization: "Bearer #{customer.jwt_token}", Accept: 'application/json' } }

  describe 'GET /show' do
    it 'renders a successful response' do
      get api_v1_customer_customer_url(customer), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { email: 'newmail@gmail.com', password: '1234567890', password_confirmation: '1234567890' } }

      it 'updates the requested draft_work' do
        patch api_v1_customer_customer_url(customer), params: { customer: new_attributes }, headers: valid_headers, as: :json
        customer.reload
        expect(customer.email).to eq('newmail@gmail.com')
      end
    end
  end
end
