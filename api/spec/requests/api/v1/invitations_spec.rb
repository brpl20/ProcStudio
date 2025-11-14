# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Invitations', type: :request do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team) }
  let(:headers) { { 'Authorization' => "Bearer #{user.jwt_token}" } }

  describe 'POST /api/v1/invitations' do
    context 'with valid params' do
      let(:valid_params) do
        {
          emails: ['user1@example.com', 'user2@example.com'],
          base_url: 'http://localhost:5173'
        }
      end

      it 'creates invitations successfully' do
        post '/api/v1/invitations', params: valid_params, headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['summary']['successful_count']).to eq(2)
      end
    end

    context 'with invalid emails' do
      let(:invalid_params) do
        {
          emails: ['invalid-email'],
          base_url: 'http://localhost:5173'
        }
      end

      it 'returns error' do
        post '/api/v1/invitations', params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end
  end

  describe 'GET /api/v1/invitations/:token/verify' do
    let(:invitation) { create(:user_invitation, invited_by: user, team: team) }

    context 'with valid token' do
      it 'returns invitation data' do
        get "/api/v1/invitations/#{invitation.token}/verify"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['valid']).to be true
        expect(json['data']['invitation']['email']).to eq(invitation.email)
      end
    end

    context 'with invalid token' do
      it 'returns error' do
        get '/api/v1/invitations/invalid-token/verify'

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end

    context 'with expired invitation' do
      let(:expired_invitation) { create(:user_invitation, :expired, invited_by: user, team: team) }

      it 'returns invalid status' do
        get "/api/v1/invitations/#{expired_invitation.token}/verify"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['valid']).to be false
        expect(json['data']['reason']).to match(/expirou/)
      end
    end
  end

  describe 'POST /api/v1/invitations/:token/accept' do
    let(:invitation) { create(:user_invitation, email: 'newuser@example.com', invited_by: user, team: team) }

    context 'with valid params' do
      let(:valid_params) do
        {
          password: 'password123',
          password_confirmation: 'password123',
          user_profile_attributes: {
            name: 'João',
            last_name: 'Silva',
            oab: '123456'
          }
        }
      end

      it 'creates user and accepts invitation' do
        post "/api/v1/invitations/#{invitation.token}/accept", params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['user']['email']).to eq('newuser@example.com')

        # Verify user was created
        expect(User.find_by(email: 'newuser@example.com')).to be_present
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          password: 'short',
          password_confirmation: 'different'
        }
      end

      it 'returns error' do
        post "/api/v1/invitations/#{invitation.token}/accept", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end
  end

  describe 'GET /api/v1/invitations' do
    let!(:invitation1) { create(:user_invitation, invited_by: user, team: team) }
    let!(:invitation2) { create(:user_invitation, :accepted, invited_by: user, team: team) }

    it 'returns all invitations for team' do
      get '/api/v1/invitations', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['data'].size).to eq(2)
    end

    context 'with status filter' do
      it 'filters by pending status' do
        get '/api/v1/invitations', params: { status: 'pending' }, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(1)
        expect(json['data'][0]['status']).to eq('pending')
      end
    end
  end

  describe 'DELETE /api/v1/invitations/:id' do
    let(:invitation) { create(:user_invitation, invited_by: user, team: team) }

    context 'with pending invitation' do
      it 'cancels invitation' do
        delete "/api/v1/invitations/#{invitation.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
      end
    end

    context 'with accepted invitation' do
      let(:accepted_invitation) { create(:user_invitation, :accepted, invited_by: user, team: team) }

      it 'returns error' do
        delete "/api/v1/invitations/#{accepted_invitation.id}", headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end
  end
end
