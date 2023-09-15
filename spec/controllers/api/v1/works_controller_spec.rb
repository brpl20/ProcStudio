# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::WorksController, type: :request do
  let!(:admin) { create(:admin) }
  let!(:office) { create(:office) }

  describe '#index' do
    let!(:work) { create(:work) }

    context 'when request is valid' do
      before do
        get '/api/v1/works', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all works' do
        expect(JSON.parse(response.body)).to eq(
          'data' => [{
            'id' => work.id.to_s,
            'type' => 'work',
            'attributes' => {
              'procedure' => work.procedure,
              'subject' => work.subject,
              'number' => work.number,
              'civel_area' => work.civel_area,
              'social_security_areas' => work.social_security_areas,
              'laborite_areas' => work.laborite_areas,
              'other_description' => work.other_description,
              'tributary_areas' => work.tributary_areas,
              'partner_lawyer' => work.partner_lawyer,
              'physical_lawyer' => work.physical_lawyer,
              'responsible_lawyer' => work.responsible_lawyer,
              'initial_atendee' => work.initial_atendee,
              'bachelor' => work.bachelor,
              'intern' => work.intern,
              'note' => work.note,
              'folder' => work.folder,
              'procurations_urls' => work.documents.procurations
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
        get '/api/v1/works', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'create' do
    let(:work) { create(:work) }
    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/works', params: {
          work: {
            procedure: 'administrative',
            subject: 'criminal',
            number: Faker::Number.number(digits: 2),
            folder: Faker::Lorem.word,
            initial_atendee: Faker::Lorem.word,
            note: Faker::Lorem.word,
            extra_pending_document: Faker::Lorem.word,
            lawyers: { 'Pellizzetti Advocacia': ['Bruno Pellizzetti', 'Marcos Souza'] }
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:created)
      end
    end
    context 'when create tries to make an request without token' do
      it 'returns :unauthorized' do
        post '/api/v1/works', params: {
          work: {
            procedure: 'administrative',
            subject: 'criminal',
            action: Faker::Lorem.word
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'nested attributes' do
      let!(:profile_customer_one) { create(:profile_customer) }
      let!(:profile_customer_two) { create(:profile_customer) }
      let!(:power) { create(:power) }

      it 'creates pending documents' do
        expect do
          post '/api/v1/works', params: {
            work: {
              procedure: 'administrative',
              subject: 'criminal',
              number: Faker::Number.number(digits: 2),
              pending_documents_attributes: [{ description: 'rg' }, { description: 'proof_of_address' }]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(PendingDocument, :count).by(2)
      end
      it 'creates powers' do
        expect do
          post '/api/v1/works', params: {
            work: {
              procedure: 'administrative',
              subject: 'criminal',
              number: Faker::Number.number(digits: 2),
              power_ids: [power.id]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(PowerWork, :count).by(1)
      end
      it 'creates office_works' do
        expect do
          post '/api/v1/works', params: {
            work: {
              procedure: 'administrative',
              subject: 'criminal',
              number: Faker::Number.number(digits: 2),
              office_ids: [office.id]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(OfficeWork, :count).by(1)
      end
      it 'creates customer_works relationship' do
        expect do
          post '/api/v1/works', params: {
            work: {
              procedure: 'administrative',
              subject: 'criminal',
              number: Faker::Number.number(digits: 2),
              profile_customer_ids: [profile_customer_one.id, profile_customer_two.id]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(CustomerWork, :count).by(2)
      end
      it 'creates recommendations' do
        expect do
          post '/api/v1/works', params: {
            work: {
              procedure: 'administrative',
              subject: 'criminal',
              number: Faker::Number.number(digits: 2),
              recommendations_attributes: [{ percentage: '30%', commission: '100', profile_customer_id: profile_customer_one.id }]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(Recommendation, :count).by(1)
      end
      it 'creates honorary' do
        expect do
          post '/api/v1/works', params: {
            work: {
              procedure: 'administrative',
              subject: 'criminal',
              number: Faker::Number.number(digits: 2),
              honorary_attributes: { fixed_honorary_value: '200%', parcelling_value: '2', honorary_type: 'success',
                                     percent_honorary_value: '10%', parcelling: true }
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(Honorary, :count).by(1)
      end
    end
  end
  describe 'update' do
    let!(:work) { create(:work, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        put '/api/v1/works/5', params: {
          work: {
            note: 'New description'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
      end
    end
    context 'when update tries to make an request without token' do
      it 'returns :unauthorized' do
        put '/api/v1/works/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'show' do
    let!(:work) { create(:work, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        get '/api/v1/works/5',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => work.id.to_s,
            'type' => 'work',
            'attributes' => {
              'procedure' => work.procedure,
              'subject' => work.subject,
              'number' => work.number,
              'civel_area' => work.civel_area,
              'social_security_areas' => work.social_security_areas,
              'laborite_areas' => work.laborite_areas,
              'other_description' => work.other_description,
              'tributary_areas' => work.tributary_areas,
              'partner_lawyer' => work.partner_lawyer,
              'physical_lawyer' => work.physical_lawyer,
              'responsible_lawyer' => work.responsible_lawyer,
              'initial_atendee' => work.initial_atendee,
              'bachelor' => work.bachelor,
              'intern' => work.intern,
              'note' => work.note,
              'folder' => work.folder,
              'procurations_urls' => work.documents.procurations
            }
          }
        )
      end
    end
    context 'when show tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/works/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when work dont exists' do
      it 'returns :not_found' do
        get '/api/v1/works/35',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
