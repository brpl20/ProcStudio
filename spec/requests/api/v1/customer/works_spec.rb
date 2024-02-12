# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/customer/works', type: :request do
  let!(:customer) { create(:customer) }
  let(:valid_headers) { { Authorization: "Bearer #{customer.jwt_token}", Accept: 'application/json' } }

  describe 'GET /index' do
    it 'renders a successful response' do
      get api_v1_customer_works_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      profile_customer = create(:profile_customer, customer: customer)
      work = create(:work, profile_customers: [profile_customer])

      get api_v1_customer_work_url(work), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end
end
