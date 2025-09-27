# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OfficesController, type: :request do
  let!(:admin) { create(:profile_admin).admin }

  describe '#index' do
    let(:office) { admin.profile_admin.office }

    context 'when request is valid' do
      before do
        get '/api/v1/offices', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all offices' do
        expect(response.parsed_body).to eq(
          'data' => [{
            'id' => office.id.to_s,
            'type' => 'office',
            'attributes' => {
              'name' => office.name,
              'cnpj' => office.cnpj,
              'city' => office.city,
              'site' => office.site,
              'office_type_description' => office.office_type.description,
              'responsible_lawyer_id' => office.responsible_lawyer_id,
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
            zip_code: '79750000',
            street: 'Rua Um',
            number: Faker::Number.number(digits: 3),
            neighborhood: 'centro',
            city: 'Nova Andradina',
            state: 'MS',
            office_type_id: FactoryBot.create(:office_type).id
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
            zip_code: '79750000',
            street: 'Rua Um',
            number: Faker::Number.number(digits: 3),
            neighborhood: 'centro',
            city: 'Nova Andradina',
            state: 'MS',
            office_type_id: FactoryBot.create(:office_type).id
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
              zip_code: '79750000',
              street: 'Rua Um',
              number: Faker::Number.number(digits: 3),
              neighborhood: 'centro',
              city: 'Nova Andradina',
              state: 'MS',
              office_type_id: FactoryBot.create(:office_type).id,
              logo: Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/Ruby.jpg'), 'image/jpg')
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
                zip_code: '79750000',
                street: 'Rua Um',
                number: Faker::Number.number(digits: 3),
                neighborhood: 'centro',
                city: 'Nova Andradina',
                state: 'MS',
                office_type_id: FactoryBot.create(:office_type).id,
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
                zip_code: '79750000',
                street: 'Rua Um',
                number: Faker::Number.number(digits: 3),
                neighborhood: 'centro',
                city: 'Nova Andradina',
                state: 'MS',
                office_type_id: FactoryBot.create(:office_type).id,
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
                zip_code: '79750000',
                street: 'Rua Um',
                number: Faker::Number.number(digits: 3),
                neighborhood: 'centro',
                city: 'Nova Andradina',
                state: 'MS',
                office_type_id: FactoryBot.create(:office_type).id,
                bank_accounts_attributes: [bank_name: 'BB', account_type: 'checking', agency: '35478', account: 254, operation: 0o02]
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
        expect(response.parsed_body).to eq(
          'data' => {
            'id' => office.id.to_s,
            'type' => 'office',
            'attributes' =>
              {
                'name' => office.name,
                'cnpj' => office.cnpj,
                'city' => office.city,
                'site' => office.site,
                'oab' => office.oab,
                'society' => office.society,
                'foundation' => office.foundation.iso8601,
                'zip_code' => office.zip_code,
                'street' => office.street,
                'number' => office.number,
                'neighborhood' => office.neighborhood,
                'state' => office.state,
                'profile_admins' => [],
                'phones' => [],
                'emails' => [],
                'bank_accounts' => [],
                'works' => [],
                'office_type_description' => office.office_type.description,
                'responsible_lawyer_id' => office.responsible_lawyer_id,
                'accounting_type' => office.accounting_type,
                'deleted' => false
              }
          }
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

  describe 'GET /api/v1/offices/with_lawyers' do
    let(:profile_admin) { admin.profile_admin }
    context 'when the request is successful' do
      before do
        get '/api/v1/offices/with_lawyers',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(200)
      end

      it 'returns lawyer attributes' do
        lawyers = response.parsed_body['data'][0]['attributes']['lawyers']
        lawyers.each do |lawyer|
          expect(lawyer['id']).to eq(profile_admin.id)
          expect(lawyer['name']).to eq(profile_admin.name)
        end
      end
    end
  end

  describe 'destroy' do
    let!(:office) { create(:office, id: 5) }
    context 'when request is valid' do
      it 'returns :no_content' do
        delete '/api/v1/offices/5', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:no_content)
      end
    end
    context 'when destroy tries to make an request without token' do
      it 'returns :unauthorized' do
        delete '/api/v1/offices/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
