# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OfficesController, type: :request do
  let!(:admin) { create(:admin) }

  describe '#index' do
    let!(:office) { create(:office) }

    context 'when request is valid' do
      before do
        get '/api/v1/offices', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all offices' do
        expect(JSON.parse(response.body)).to eq(
          'data' => [{
            'id' => office.id.to_s,
            'type' => 'office',
            'attributes' => {
              'name' => office.name,
              'cnpj' => office.cnpj,
              'oab' => office.oab,
              'society' => office.society,
              'foundation' => office.foundation.iso8601,
              'site' => office.site,
              'cep' => office.cep,
              'street' => office.street,
              'number' => office.number,
              'neighborhood' => office.neighborhood,
              'city' => office.city,
              'state' => office.state,
              'profile_admin_id' => office.profile_admin_id,
              'office_type_id' => office.office_type_id
            },
            'relationships' => {
              'office_phones' => { 'data' => [] },
              'office_emails' => { 'data' => [] },
              'office_bank_accounts' => { 'data' => [] }
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
        get '/api/v1/offices', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'create' do
    let(:customer) { create(:customer) }
    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/offices', params: {
          office: {
            name: Faker::Company.name,
            cnpj: Faker::Number.number(digits: 14),
            oab: Faker::Number.number(digits: 6),
            society: 'company',
            foundation: Faker::Date.birthday(min_age: 18, max_age: 65),
            site: Faker::Internet.url,
            cep: '79750000',
            street: 'Rua Um',
            number: Faker::Number.number(digits: 3),
            neighborhood: 'centro',
            city: 'Nova Andradina',
            state: 'MS',
            office_type_id: FactoryBot.create(:office_type).id,
            profile_admin_id: FactoryBot.create(:profile_admin).id
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:created)
      end
    end
    context 'when create tries to make an request without token' do
      it 'returns :unauthorized' do
        post '/api/v1/offices', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'update' do
    let!(:office) { create(:office, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        put '/api/v1/offices/5', params: {
          office: {
            name: 'Nome Novo'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => office.id.to_s,
            'type' => 'office',
            'attributes' => {
              'name' => 'Nome Novo',
              'cnpj' => office.cnpj,
              'oab' => office.oab,
              'society' => office.society,
              'foundation' => office.foundation.iso8601,
              'site' => office.site,
              'cep' => office.cep,
              'street' => office.street,
              'number' => office.number,
              'neighborhood' => office.neighborhood,
              'city' => office.city,
              'state' => office.state,
              'profile_admin_id' => office.profile_admin_id,
              'office_type_id' => office.office_type_id
            },
            'relationships' => {
              'office_phones' => { 'data' => [] },
              'office_emails' => { 'data' => [] },
              'office_bank_accounts' => { 'data' => [] }
            }
          }
        )
      end
    end
    context 'when update tries to make an request without token' do
      it 'returns :unauthorized' do
        put '/api/v1/offices/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'show' do
    let!(:office) { create(:office, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        get '/api/v1/offices/5',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => office.id.to_s,
            'type' => 'office',
            'attributes' => {
              'name' => office.name,
              'cnpj' => office.cnpj,
              'oab' => office.oab,
              'society' => office.society,
              'foundation' => office.foundation.iso8601,
              'site' => office.site,
              'cep' => office.cep,
              'street' => office.street,
              'number' => office.number,
              'neighborhood' => office.neighborhood,
              'city' => office.city,
              'state' => office.state,
              'profile_admin_id' => office.profile_admin_id,
              'office_type_id' => office.office_type_id
            },
            'relationships' => {
              'office_phones' => { 'data' => [] },
              'office_emails' => { 'data' => [] },
              'office_bank_accounts' => { 'data' => [] }
            }
          }, 'included' => []
        )
      end
    end
    context 'when show tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/offices/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when office dont exists' do
      it 'returns :not_found' do
        get '/api/v1/offices/35',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
