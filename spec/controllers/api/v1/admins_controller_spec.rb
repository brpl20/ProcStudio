# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AdminsController, type: :request do
  let!(:admin) { create(:profile_admin).admin }
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
              'email' => admin.email,
              'deleted' => false
            },
            'relationships' => {
              'profile_admin' => {
                'data' => {
                  'id' => admin.profile_admin.id.to_s,
                  'type' => 'profile_admin'
                }
              }
            }
          }],
          'included' => [
            'id' => admin.profile_admin.id.to_s,
            'type' => 'profile_admin',
            'attributes' => {
              'role' => admin.profile_admin.role,
              'name' => admin.profile_admin.name,
              'last_name' => admin.profile_admin.last_name,
              'email' => admin.email
            }
          ],
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
    let(:admin) { create(:profile_admin).admin }
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
                birth: Faker::Date.birthday(min_age: 18, max_age: 65),
                oab: Faker::Number.number(digits: 6),
                civil_status: 'single',
                gender: 'male',
                nationality: 'brazilian'
              }
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(ProfileAdmin, :count).by(1)
      end
    end
  end
  describe 'update' do
    let!(:admin) { create(:profile_admin).admin }
    context 'when request is valid' do
      it 'returns :ok' do
        put "/api/v1/admins/#{admin.id}", params: {
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
              'email' => 'emailnovo@gmail.com',
              'deleted' => false
            },
            'relationships' => {
              'profile_admin' => {
                'data' => {
                  'id' => admin.profile_admin.id.to_s,
                  'type' => 'profile_admin'
                }
              }
            }
          }
        )
      end
    end
    context 'when update tries to make an request without token' do
      it 'returns :unauthorized' do
        put "/api/v1/admins/#{admin.id}", params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'show' do
    let!(:admin) { create(:profile_admin).admin }
    context 'when request is valid' do
      it 'returns :ok' do
        get "/api/v1/admins/#{admin.id}", headers: {
          Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json'
        }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => admin.id.to_s,
            'type' => 'admin',
            'attributes' => {
              'email' => admin.email,
              'deleted' => false
            },
            'relationships' => {
              'profile_admin' => {
                'data' => {
                  'id' => admin.profile_admin.id.to_s,
                  'type' => 'profile_admin'
                }
              }
            }
          },
          'included' => [
            'id' => admin.profile_admin.id.to_s,
            'type' => 'profile_admin',
            'attributes' => {
              'role' => admin.profile_admin.role,
              'name' => admin.profile_admin.name,
              'last_name' => admin.profile_admin.last_name,
              'email' => admin.email
            }
          ]
        )
      end
    end
    context 'when show tries to make an request without token' do
      it 'returns :unauthorized' do
        get "/api/v1/admins/#{admin.id}", params: {}

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

  describe 'destroy' do
    let!(:admin) { create(:profile_admin).admin }
    context 'when request is valid' do
      it 'returns :no_content' do
        delete "/api/v1/admins/#{admin.id}", headers: {
          Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json'
        }
        expect(response).to have_http_status(:no_content)
      end
    end
    context 'when destroy tries to make an request without token' do
      it 'returns :unauthorized' do
        delete "/api/v1/admins/#{admin.id}", params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
