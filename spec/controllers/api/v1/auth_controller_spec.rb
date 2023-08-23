# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Api::V1::AuthController, type: :request do
  let!(:admin) { create(:admin) }
  let!(:jwt_token) do
    JWT.encode({ admin_id: admin.id, exp: Time.now.to_i + 3600 }, Rails.application.secret_key_base)
  end
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'POST /api/v1/login' do
    context 'Quando e-mail e senha informados são válidos' do
      it 'Retorna um token válido' do
        post '/api/v1/login', params: {
          auth: {
            email: admin.email,
            password: admin.password
          }
        }
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['token']).not_to be_empty

        token_payload, _token_header = JWT.decode(json_response['token'], Rails.application.secret_key_base, true, algorithm: 'HS256')
        expect(token_payload['admin_id']).to eq(admin.id)
        expect(Time.now.to_i < token_payload['exp']).to be_truthy
      end

      it 'Atualiza admin com um novo token' do
        admin.update(jwt_token: nil)
        expect(admin.jwt_token).to be_nil

        post '/api/v1/login', params: {
          auth: {
            email: admin.email,
            password: admin.password
          }
        }
        expect(response).to have_http_status(:ok)

        admin.reload
        expect(admin.jwt_token).not_to be_nil
      end
    end

    context 'Quando e-mail ou senha inválidos são fornecidos' do
      it 'Retorna inválido' do
        post '/api/v1/login', params: {
          auth: {
            email: admin.email,
            password: 'wrong_password'
          }
        }
        expect(response).to have_http_status(:unauthorized)
        begin
          json_response = JSON.parse(response.body)
        rescue JSON::ParserError
          json_response = {}
        end

        expect(json_response).to be_a(Hash)
        expect(json_response['token']).to be_nil
      end

      it 'Não atualiza admin com um novo token' do
        post '/api/v1/login', params: {
          auth: {
            email: admin.email,
            password: 'wrong_password'
          }
        }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/logout' do
    context 'Quando usuário está logado' do
      it 'Revoga o token' do
        delete '/api/v1/logout', headers: headers
        expect(response).to have_http_status(:success)
        expect(admin.reload.jwt_token).to be_nil
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to eq(true)
        expect(response_body['message']).to eq('Saiu com successo')
      end
    end

    context 'Quando usuário não está autenticado' do
      let(:headers) { {} }

      it 'Retorna não autorizado' do
        admin.update_attribute(:jwt_token, jwt_token)

        delete '/api/v1/logout', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(admin.reload.jwt_token).not_to be_nil

        response_body = JSON.parse(response.body)
        expect(response_body['success']).to eq(false)
        expect(response_body['message']).to eq('Usuário não autorizado')
      end
    end

    context 'Quando o token está expirado' do
      let(:jwt_token) { JWT.encode({ admin_id: admin.id, exp: Time.now.to_i - (99 * 3600) }, Rails.application.secret_key_base) }
      let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

      it 'Retorna não autorizado e não revoga token' do
        admin.update_attribute(:jwt_token, jwt_token)

        delete '/api/v1/logout', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(admin.reload.jwt_token).not_to be_nil

        response_body = JSON.parse(response.body)
        expect(response_body['success']).to eq(false)
        expect(response_body['message']).to eq('Usuário não autorizado')
      end
    end
  end

  describe '#authenticate' do
    context 'when authenticating with Google' do
      let(:access_token) { 'valid_access_token' }
      let(:email) { 'user@example.com' }
      let(:admin) { create(:admin, email: email) }

      before do
        allow(controller).to receive(:params).and_return({ provider: 'google', accessToken: access_token })

        stub_request(:get, "https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=#{access_token}")
          .to_return(status: 200, body: { 'email' => email }.to_json, headers: {})

        allow(Admin).to receive(:find_for_authentication).with(email: email).and_return(admin)
        allow(controller).to receive(:update_user_token).with(admin).and_return('fake_token')
      end

      it 'finds the admin and returns a token' do
        post '/api/v1/login', params: {
          provider: 'google',
          accessToken: access_token
        }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when authenticating with Google' do
      let(:access_token) { 'valid_access_token' }
      let(:email) { 'user@example.com' }

      before do
        allow(controller).to receive(:auth_params).and_return({ provider: 'google', accessToken: access_token })

        stub_request(:get, "https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=#{access_token}")
          .to_return(status: 200, body: { 'email' => email }.to_json, headers: {})
      end

      it 'returns not found if admin with email is not found' do
        allow(Admin).to receive(:find_for_authentication).with(email: email).and_return(nil)

        post '/api/v1/login', params: {
          provider: 'google',
          accessToken: access_token
        }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
