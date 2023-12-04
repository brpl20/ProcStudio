# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OfficeTypesController, type: :request do
  let(:valid_header) { { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' } }

  let(:admin) { create(:admin) }
  let!(:office_type) { create(:office_type) }

  describe '#index (GET api/v1/office_types)' do
    context 'when a request is valid' do
      before do
        get '/api/v1/office_types', params: {}, headers: valid_header
      end

      it 'returns status code 200 (OK)' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all office types' do
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response.dig(:meta, :total_count)).to eq(1)
      end
    end

    context 'when a request is invalid' do
      it 'returns status code 401 (unauthorized)' do
        get '/api/v1/office_types', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe '#show (GET api/v1/office_types/:id)' do
    context 'when a request is valid' do
      before do
        get "/api/v1/office_types/#{office_type.id}", params: {}, headers: valid_header
      end

      it 'returns status code 200 (OK)' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns an office type' do
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response.dig(:data, :id)).to eq(office_type.id.to_s)
        expect(json_response.dig(:data, :attributes, :description)).to eq(office_type.description)
      end
    end

    context 'when a request is invalid' do
      it 'returns status code 401 (unauthorized)' do
        get "/api/v1/office_types/#{office_type.id}", params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe '#create (POST api/v1/office_types)' do
    let(:params) { { office_type: { description: 'Escritório' } } }

    context 'when a request is valid' do
      before do
        post '/api/v1/office_types', params: params, headers: valid_header
      end

      it 'returns status code 201 (created)' do
        expect(response).to have_http_status(:created)
      end

      it 'returns the office type data' do
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response.dig(:data, :attributes, :description)).to eq('Escritório')
      end
    end

    context 'when a request is invalid' do
      it 'returns status code 401 (unauthorized)' do
        post '/api/v1/office_types', params: params

        expect(response).to have_http_status(:unauthorized)
      end

      describe 'when there are params missing or validation issues' do
        it 'returns status code 422 (unprocessable entity) when description is missing' do
          post '/api/v1/office_types', params: { office_type: { description: '' } }, headers: valid_header

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns status code 422 (unprocessable entity) when description is in use' do
          post '/api/v1/office_types', params: { office_type: { description: office_type.description } }, headers: valid_header

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe '#update (PUT api/v1/office_types/:id)' do
    let(:params) { { office_type: { description: 'Escritório' } } }

    context 'when a request is valid' do
      before do
        put "/api/v1/office_types/#{office_type.id}", params: params, headers: valid_header
      end

      it 'returns status code 200 (OK)' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the office type data' do
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response.dig(:data, :attributes, :description)).to eq('Escritório')
      end
    end

    context 'when a request is invalid' do
      it 'returns status code 401 (unauthorized)' do
        put "/api/v1/office_types/#{office_type.id}", params: params

        expect(response).to have_http_status(:unauthorized)
      end

      describe 'when there are params missing or validation issues' do
        it 'returns status code 422 (unprocessable entity) when description is missing' do
          put "/api/v1/office_types/#{office_type.id}", params: { office_type: { description: '' } }, headers: valid_header

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe '#destroy (DELETE api/v1/office_types/:id)' do
    context 'when a request is valid' do
      before do
        delete "/api/v1/office_types/#{office_type.id}", params: {}, headers: valid_header
      end

      it 'returns status code 404 (not_found)' do
        expect(response).to have_http_status(:not_found)
        expect(OfficeType.exists?(office_type.id)).to eq(false)
      end
    end
  end
end
