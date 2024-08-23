# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProfileAdminsController, type: :request do
  let!(:profile_admin) { create(:profile_admin) }
  let(:admin) { profile_admin.admin }
  let(:office) { profile_admin.office }

  describe '#index' do
    context 'when request is valid' do
      before do
        get '/api/v1/profile_admins', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all profile_admins' do
        expect(JSON.parse(response.body)).to eq(
          'data' => [{
            'id' => profile_admin.id.to_s,
            'type' => 'profile_admin',
            'attributes' => {
              'email' => profile_admin.admin.email,
              'role' => profile_admin.role,
              'name' => profile_admin.name,
              'last_name' => profile_admin.last_name,
              'deleted' => false
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
        get '/api/v1/profile_admins', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'create' do
    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/profile_admins', params: {
          profile_admin: {
            role: 'lawyer',
            status: 'active',
            admin_id: admin.id,
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
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:created)
      end
    end
    context 'when request is invalid' do
      it 'returns :bad_request' do
        post '/api/v1/profile_admins', params: {
          profile_admin: {
            role: 'lawyer',
            status: 'active',
            office_id: office.id,
            name: 'John',
            last_name: 'Doe',
            cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
            rg: Faker::IDNumber.brazilian_id(formatted: true),
            birth: Faker::Date.birthday(min_age: 18, max_age: 65)
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when send phones_attributes' do
      it 'creates a admin' do
        expect do
          post '/api/v1/profile_admins', params: {
            profile_admin: {
              role: 'lawyer',
              status: 'active',
              office_id: office.id,
              admin_id: admin.id,
              name: 'John',
              last_name: 'Doe',
              cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
              rg: Faker::IDNumber.brazilian_id(formatted: true),
              birth: Faker::Date.birthday(min_age: 18, max_age: 65),
              oab: Faker::Number.number(digits: 6),
              civil_status: 'single',
              gender: 'male',
              nationality: 'brazilian',
              phones_attributes: [phone_number: Faker::PhoneNumber.cell_phone]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(AdminPhone, :count).by(1)
      end
    end
  end

  describe 'destroy' do
    context 'when request is valid' do
      it 'returns :no_content' do
        delete "/api/v1/profile_admins/#{profile_admin.id}", headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:no_content)
      end
    end
    context 'when request is invalid' do
      it 'returns :unauthorized' do
        delete "/api/v1/profile_admins/#{profile_admin.id}", params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
