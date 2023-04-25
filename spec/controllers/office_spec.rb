# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Offices', type: :request do
  let(:admin) { create(:admin) } # cria o usuário de teste com o token JWT válido

  describe 'GET /api/v1/offices' do
    context 'Quando autenticado' do
      before do
        get '/api/v1/offices', headers: { 'Authorization': "Bearer #{admin.jwt_token}", 'Accept': 'application/json' }
      end

      it 'Retorna 200' do
        expect(response.status).to eq(200)
      end

      it 'Retorna JSON' do
        expect(response.content_type).to match(/application\/json/)
      end
    end

    context 'Quando não autenticado' do
      before { get '/api/v1/offices' }

      it 'Retorna 401' do
        expect(response.status).to eq 401
      end
    end
  end
end
