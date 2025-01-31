# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProfileCustomersController, type: :request do
  let!(:admin) { create(:profile_admin).admin }

  describe '#index' do
    let!(:profile_customer) { create(:profile_customer) }

    context 'when request is valid' do
      before do
        get '/api/v1/profile_customers', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all profile_customers' do
        serialized_addresses = profile_customer.addresses.map do |address|
          {
            'id' => address.id,
            'description' => address.description,
            'zip_code' => address.zip_code,
            'number' => address.number,
            'neighborhood' => address.neighborhood,
            'city' => address.city,
            'state' => address.state,
            'street' => address.street
          }
        end

        expect(JSON.parse(response.body)).to eq(
          'data' => [{
            'id' => profile_customer.id.to_s,
            'type' => 'profile_customer',
            'attributes' => {
              'customer_type' => profile_customer.customer_type,
              'name' => profile_customer.name,
              'last_name' => profile_customer.last_name,
              'phones' => [],
              'represent' => nil,
              'addresses' => serialized_addresses,
              'emails' => [],
              'cpf' => profile_customer.cpf,
              'cnpj' => profile_customer.cnpj,
              'default_phone' => nil,
              'default_email' => nil,
              'city' => profile_customer.addresses.first.city,
              'customer_files' => [],
              'deleted' => false,
              'bank_accounts' => []
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
        get '/api/v1/profile_customers', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'create' do
    let(:customer) { create(:customer) }
    before { allow(Customers::Mail::WelcomeService).to receive(:call).and_return(true) }
    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/profile_customers', params: {
          profile_customer: {
            customer_id: customer.id,
            name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
            rg: Faker::IDNumber.brazilian_id(formatted: true),
            birth: Faker::Date.birthday(min_age: 18, max_age: 65),
            gender: 'male',
            capacity: 'able',
            civil_status: 'single',
            nationality: 'brazilian',
            profession: Faker::Job.title
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:created)
      end
    end
    context 'nested attributes' do
      it 'creates address' do
        expect do
          post '/api/v1/profile_customers', params: {
            profile_customer: {
              customer_id: customer.id,
              name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
              rg: Faker::IDNumber.brazilian_id(formatted: true),
              birth: Faker::Date.birthday(min_age: 18, max_age: 65),
              gender: 'male',
              capacity: 'able',
              civil_status: 'single',
              nationality: 'brazilian',
              profession: Faker::Job.title,
              addresses_attributes: [{
                description: Faker::Address.street_name,
                zip_code: Faker::Address.zip_code,
                street: Faker::Address.street_name,
                number: Faker::Address.building_number,
                neighborhood: Faker::Address.community,
                city: Faker::Address.city,
                state: Faker::Address.state
              }]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(CustomerAddress, :count).by(1)
      end
      it 'creates bank account' do
        expect do
          post '/api/v1/profile_customers', params: {
            profile_customer: {
              customer_id: customer.id,
              name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
              rg: Faker::IDNumber.brazilian_id(formatted: true),
              birth: Faker::Date.birthday(min_age: 18, max_age: 65),
              gender: 'male',
              capacity: 'able',
              civil_status: 'single',
              nationality: 'brazilian',
              profession: Faker::Job.title,
              bank_accounts_attributes: [bank_name: 'BB', type_account: 'CC', agency: '35478',
                                         account: '254', operation: '0002', pix: '12435687968']
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(CustomerBankAccount, :count).by(1)
      end

      it 'creates phone' do
        expect do
          post '/api/v1/profile_customers', params: {
            profile_customer: {
              customer_id: customer.id,
              name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
              rg: Faker::IDNumber.brazilian_id(formatted: true),
              birth: Faker::Date.birthday(min_age: 18, max_age: 65),
              gender: 'male',
              capacity: 'able',
              civil_status: 'single',
              nationality: 'brazilian',
              profession: Faker::Job.title,
              phones_attributes: [phone_number: Faker::PhoneNumber.cell_phone]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(CustomerPhone, :count).by(1)
      end

      it 'creates email' do
        expect do
          post '/api/v1/profile_customers', params: {
            profile_customer: {
              customer_id: customer.id,
              name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
              rg: Faker::IDNumber.brazilian_id(formatted: true),
              birth: Faker::Date.birthday(min_age: 18, max_age: 65),
              gender: 'male',
              capacity: 'able',
              civil_status: 'single',
              nationality: 'brazilian',
              profession: Faker::Job.title,
              emails_attributes: [email: Faker::Internet.email]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(CustomerEmail, :count).by(1)
      end
      it 'creates customer' do
        expect do
          post '/api/v1/profile_customers', params: {
            profile_customer: {
              customer_id: customer.id,
              name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
              rg: Faker::IDNumber.brazilian_id(formatted: true),
              birth: Faker::Date.birthday(min_age: 18, max_age: 65),
              gender: 'male',
              capacity: 'able',
              civil_status: 'single',
              nationality: 'brazilian',
              profession: Faker::Job.title,
              customer_attributes: [email: Faker::Internet.email, password: 123_456, password_confirmation: 123_456]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(Customer, :count).by(1)
      end
      it 'creates customer file' do
        expect do
          post '/api/v1/profile_customers', params: {
            profile_customer: {
              customer_id: customer.id,
              name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              cpf: Faker::IDNumber.brazilian_citizen_number(formatted: true),
              rg: Faker::IDNumber.brazilian_id(formatted: true),
              birth: Faker::Date.birthday(min_age: 18, max_age: 65),
              gender: 'male',
              capacity: 'able',
              civil_status: 'single',
              nationality: 'brazilian',
              profession: Faker::Job.title,
              customer_files_attributes: [file_description: 'simple_procuration',
                                          document_docx: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'factories', 'images', 'Ruby.jpg'), 'image/jpg')]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(CustomerFile, :count).by(1)
      end
    end
    context 'when create tries to make an request without token' do
      it 'returns :unauthorized' do
        post '/api/v1/profile_customers', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'update' do
    let!(:profile_customer) { create(:profile_customer, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        put '/api/v1/profile_customers/5', params: {
          profile_customer: {
            name: 'Nome Novo'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
      end
    end
    context 'when update tries to make an request without token' do
      it 'returns :unauthorized' do
        put '/api/v1/profile_customers/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'show' do
    let!(:profile_customer) { create(:profile_customer, id: 5) }
    before { profile_customer.addresses.delete_all }
    context 'when request is valid' do
      it 'returns :ok' do
        get '/api/v1/profile_customers/5',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => profile_customer.id.to_s,
            'type' => 'profile_customer',
            'attributes' => {
              'name' => profile_customer.name,
              'last_name' => profile_customer.last_name,
              'cpf' => profile_customer.cpf,
              'cnpj' => profile_customer.cnpj,
              'customer_type' => profile_customer.customer_type,
              'gender' => profile_customer.gender,
              'inss_password' => profile_customer.inss_password,
              'rg' => profile_customer.rg,
              'nationality' => profile_customer.nationality,
              'civil_status' => profile_customer.civil_status,
              'capacity' => profile_customer.capacity,
              'profession' => profile_customer.profession,
              'company' => profile_customer.company,
              'birth' => profile_customer.birth.iso8601,
              'mother_name' => profile_customer.mother_name,
              'number_benefit' => profile_customer.number_benefit,
              'status' => profile_customer.status,
              'nit' => profile_customer.nit,
              'customer_id' => profile_customer.customer_id,
              'emails' => [],
              'addresses' => [],
              'bank_accounts' => [],
              'phones' => [],
              'default_phone' => nil,
              'default_email' => nil,
              'city' => nil,
              'represent' => nil,
              'accountant_id' => nil,
              'customer_files' => [],
              'created_by_id' => profile_customer.created_by_id,
              'deleted' => false
            }
          }
        )
      end
    end
    context 'when show tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/profile_customers/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when profile_customer dont exists' do
      it 'returns :not_found' do
        get '/api/v1/profile_customers/35',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'destroy' do
    let!(:profile_customer) { create(:profile_customer, id: 5) }
    context 'when request is valid' do
      it 'returns :no_content' do
        delete '/api/v1/profile_customers/5',
               headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:no_content)
      end
    end
    context 'when destroy tries to make an request without token' do
      it 'returns :unauthorized' do
        delete '/api/v1/profile_customers/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when profile_customer dont exists' do
      it 'returns :not_found' do
        delete '/api/v1/profile_customers/35',
               headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
