# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CustomersController, type: :request do
  let!(:admin) { create(:profile_admin).admin }

  describe '#index' do
    let!(:customer) { create(:customer) }

    context 'when request is valid' do
      before do
        get '/api/v1/customers', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all customers' do
        expect(JSON.parse(response.body)).to eq(
          'data' => [{
            'id' => customer.id.to_s,
            'type' => 'customer',
            'attributes' => {
              'profile_customer_id' => customer.profile_customer_id,
              'email' => customer.email,
              'created_by_id' => customer.created_by_id,
              'confirmed_at' => customer.confirmed_at,
              'confirmed' => customer.confirmed?
            }
          }],
          'meta' => {
            'total_count' => 1
          }
        )
      end
    end
    context 'when index tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/customers', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'create' do
    let(:customer) { create(:customer) }
    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/customers', params: {
          customer: {
            email: Faker::Internet.email,
            password: '123456',
            password_confirmation: '123456'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:created)
      end
    end
    context 'when create tries to make an request without token' do
      it 'returns :unauthorized' do
        post '/api/v1/customers', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'update' do
    let!(:customer) { create(:customer, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        put '/api/v1/customers/5', params: {
          customer: {
            email: 'emailnovo@gmail.com'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => customer.id.to_s,
            'type' => 'customer',
            'attributes' => {
              'profile_customer_id' => customer.profile_customer_id,
              'email' => 'emailnovo@gmail.com',
              'created_by_id' => customer.created_by_id,
              'confirmed_at' => customer.confirmed_at,
              'confirmed' => customer.confirmed?
            }
          }
        )
      end
    end
    context 'when update tries to make an request without token' do
      it 'returns :unauthorized' do
        put '/api/v1/customers/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'show' do
    let!(:customer) { create(:customer, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        get '/api/v1/customers/5',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => customer.id.to_s,
            'type' => 'customer',
            'attributes' => {
              'profile_customer_id' => customer.profile_customer_id,
              'email' => customer.email,
              'created_by_id' => customer.created_by_id,
              'confirmed_at' => customer.confirmed_at,
              'confirmed' => customer.confirmed?
            }
          }
        )
      end
    end
    context 'when show tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/customers/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when customer dont exists' do
      it 'returns :not_found' do
        get '/api/v1/customers/35',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'destroy' do
    let!(:customer) { create(:customer, id: 5) }
    context 'when request is valid' do
      it 'returns :no_content' do
        delete '/api/v1/customers/5',
               headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:no_content)
      end
    end
    context 'when destroy tries to make an request without token' do
      it 'returns :unauthorized' do
        delete '/api/v1/customers/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when customer dont exists' do
      it 'returns :not_found' do
        delete '/api/v1/customers/35',
               headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
