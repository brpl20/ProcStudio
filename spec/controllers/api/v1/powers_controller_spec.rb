# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PowersController, type: :request do
  let!(:admin) { create(:profile_admin).admin }

  describe '#index' do
    let!(:power) { create(:power) }

    context 'when request is valid' do
      before do
        get '/api/v1/powers', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all powers' do
        expect(JSON.parse(response.body)).to eq(
          'data' => [{
            'id' => power.id.to_s,
            'type' => 'power',
            'attributes' => {
              'description' => power.description,
              'category' => power.category,
              'id' => power.id
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
        get '/api/v1/powers', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'create' do
    let(:power) { create(:power) }
    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/powers', params: {
          power: {
            description: 'texto',
            category: :lawgeneral
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:created)
      end
    end
    context 'when create tries to make an request without token' do
      it 'returns :unauthorized' do
        post '/api/v1/powers', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'update' do
    let!(:power) { create(:power, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        put '/api/v1/powers/5', params: {
          power: {
            description: 'New description'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => power.id.to_s,
            'type' => 'power',
            'attributes' => {
              'description' => 'New description',
              'category' => power.category,
              'id' => power.id
            }
          }
        )
      end
    end
    context 'when update tries to make an request without token' do
      it 'returns :unauthorized' do
        put '/api/v1/powers/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'show' do
    let!(:power) { create(:power, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        get '/api/v1/powers/5',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => power.id.to_s,
            'type' => 'power',
            'attributes' => {
              'description' => power.description,
              'category' => power.category,
              'id' => power.id
            }
          }
        )
      end
    end
    context 'when show tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/powers/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when power dont exists' do
      it 'returns :not_found' do
        get '/api/v1/powers/35',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'destroy' do
    let!(:power) { create(:power) }
    context 'when request is valid' do
      it 'returns :no_content' do
        delete "/api/v1/powers/#{power.id}", headers: {
          Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json'
        }
        expect(response).to have_http_status(:no_content)
      end
    end
    context 'when destroy tries to make an request without token' do
      it 'returns :unauthorized' do
        delete "/api/v1/powers/#{power.id}", params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
