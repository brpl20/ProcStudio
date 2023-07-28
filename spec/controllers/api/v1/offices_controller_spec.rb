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
              'state' => office.state
            },
            'relationships' => {
              'office_phones' => { 'data' => [] },
              'office_emails' => { 'data' => [] },
              'office_bank_accounts' => { 'data' => [] },
              'works' => { 'data' => [] }
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
            state: 'MS'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:created)
      end

      it 'uploads a logo' do
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
            state: 'MS'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:created)
      end

      it 'saves logo image' do
        expect do
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
              logo: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'factories', 'images', 'Ruby.jpg'), 'image/jpg')
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(ActiveStorage::Attachment, :count).by(1)
      end

      context 'create nested attributes' do
        it 'creates phones' do
          expect do
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
                phones_attributes: [phone_number: '123456789']
              }
            }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
          end.to change(OfficePhone, :count).by(1)
        end
        it 'creates email' do
          expect do
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
                emails_attributes: [email: Faker::Internet.email]
              }
            }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
          end.to change(OfficeEmail, :count).by(1)
        end
        it 'creates bank account' do
          expect do
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
                bank_accounts_attributes: [bank_name: 'BB', type_account: 'CC', agency: '35478', account: 254, operation: 0o02]
              }
            }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
          end.to change(OfficeBankAccount, :count).by(1)
        end
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
              'state' => office.state
            },
            'relationships' => {
              'office_phones' => { 'data' => [] },
              'office_emails' => { 'data' => [] },
              'office_bank_accounts' => { 'data' => [] },
              'works' => { 'data' => [] }
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
              'state' => office.state
            },
            'relationships' => {
              'office_phones' => { 'data' => [] },
              'office_emails' => { 'data' => [] },
              'office_bank_accounts' => { 'data' => [] },
              'works' => { 'data' => [] }
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
