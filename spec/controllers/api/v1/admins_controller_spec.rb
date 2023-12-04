# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AdminsController, type: :request do
  let!(:admin) { create(:admin) }
  let!(:office) { create(:office) }

  describe '#index' do
    context 'when request is valid' do
      before do
        get '/api/v1/admins', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all admins' do
        expect(JSON.parse(response.body)).to eq(
          'data' => [{
            'id' => admin.id.to_s,
            'type' => 'admin',
            'attributes' => {
              'email' => admin.email
            },
            'relationships' => {
              'profile_admin' => { 'data' => nil }
            }
          }],
          'included' => [],
          'meta' => {
            'total_count' => 1
          }
        )
      end
    end
    context 'when index tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/admins', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'create' do
    let(:admin) { create(:admin) }
    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/admins', params: {
          admin: {
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
        post '/api/v1/admins', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'nested attributes' do
      it 'creates profile admins' do
        expect do
          post '/api/v1/admins', params: {
            admin: {
              email: Faker::Internet.email,
              password: '123456',
              password_confirmation: '123456',
              profile_admin_attributes: {
                role: 'lawyer',
                status: 'active',
                office_id: office.id,
                name: 'John',
                last_name: 'Doe',
                cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
                rg: Faker::IDNumber.brazilian_id(formatted: true),
                birth: Faker::Date.birthday(min_age: 18, max_age: 65)
              }
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(ProfileAdmin, :count).by(1)
      end
    end
  end
  describe 'update' do
    let!(:admin) { create(:admin, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        put '/api/v1/admins/5', params: {
          admin: {
            email: 'emailnovo@gmail.com'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => admin.id.to_s,
            'type' => 'admin',
            'attributes' => {
              'email' => 'emailnovo@gmail.com'
            },
            'relationships' => {
              'profile_admin' => { 'data' => nil }
            }
          }
        )
      end
    end
    context 'when update tries to make an request without token' do
      it 'returns :unauthorized' do
        put '/api/v1/admins/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'show' do
    let!(:admin) { create(:admin, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        get '/api/v1/admins/5',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => admin.id.to_s,
            'type' => 'admin',
            'attributes' => {
              'email' => admin.email
            },
            'relationships' => {
              'profile_admin' => { 'data' => nil }
            }
          },
          'included' => []
        )
      end
    end
    context 'when show tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/admins/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when admin dont exists' do
      it 'returns :not_found' do
        get '/api/v1/admins/35',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
