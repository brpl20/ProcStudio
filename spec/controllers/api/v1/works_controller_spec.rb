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
              'action' => work.action,
              'number' => work.number,
              'rate_percentage' => work.rate_percentage,
              'rate_percentage_exfield' => work.rate_percentage_exfield,
              'rate_fixed' => work.rate_fixed,
              'rate_parceled_exfield' => work.rate_parceled_exfield,
              'folder' => work.folder,
              'initial_atendee' => work.initial_atendee,
              'note' => work.note,
              'checklist' => work.checklist,
              'extra_pending_document' => work.extra_pending_document
            },
            'relationships' => {
              'jobs' => { 'data' => [] },
              'powers' => { 'data' => [] },
              'profile_customers' => { 'data' => [] },
              'offices' => { 'data' => [] }
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
            subject: Faker::Lorem.word,
            action: Faker::Lorem.word,
            number: Faker::Number.number(digits: 2),
            rate_percentage: Faker::Number.number(digits: 2),
            rate_percentage_exfield: Faker::Number.number(digits: 2),
            rate_fixed: Faker::Number.number(digits: 2),
            rate_parceled_exfield: Faker::Number.number(digits: 2),
            folder: Faker::Lorem.word,
            initial_atendee: Faker::Lorem.word,
            note: Faker::Lorem.word,
            checklist: Faker::Lorem.word,
            extra_pending_document: Faker::Lorem.word
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
            subject: Faker::Lorem.word,
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
              subject: Faker::Lorem.word,
              action: Faker::Lorem.word,
              number: Faker::Number.number(digits: 2),
              rate_percentage: Faker::Number.number(digits: 2),
              rate_percentage_exfield: Faker::Number.number(digits: 2),
              rate_fixed: Faker::Number.number(digits: 2),
              rate_parceled_exfield: Faker::Number.number(digits: 2),
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
              subject: Faker::Lorem.word,
              action: Faker::Lorem.word,
              number: Faker::Number.number(digits: 2),
              rate_percentage: Faker::Number.number(digits: 2),
              rate_percentage_exfield: Faker::Number.number(digits: 2),
              rate_fixed: Faker::Number.number(digits: 2),
              rate_parceled_exfield: Faker::Number.number(digits: 2),
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
              subject: Faker::Lorem.word,
              action: Faker::Lorem.word,
              number: Faker::Number.number(digits: 2),
              rate_percentage: Faker::Number.number(digits: 2),
              rate_percentage_exfield: Faker::Number.number(digits: 2),
              rate_fixed: Faker::Number.number(digits: 2),
              rate_parceled_exfield: Faker::Number.number(digits: 2),
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
              subject: Faker::Lorem.word,
              action: Faker::Lorem.word,
              number: Faker::Number.number(digits: 2),
              rate_percentage: Faker::Number.number(digits: 2),
              rate_percentage_exfield: Faker::Number.number(digits: 2),
              rate_fixed: Faker::Number.number(digits: 2),
              rate_parceled_exfield: Faker::Number.number(digits: 2),
              profile_customer_ids: [profile_customer_one.id, profile_customer_two.id]
            }
          }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        end.to change(CustomerWork, :count).by(2)
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
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => work.id.to_s,
            'type' => 'work',
            'attributes' => {
              'procedure' => work.procedure,
              'subject' => work.subject,
              'action' => work.action,
              'number' => work.number,
              'rate_percentage' => work.rate_percentage,
              'rate_percentage_exfield' => work.rate_percentage_exfield,
              'rate_fixed' => work.rate_fixed,
              'rate_parceled_exfield' => work.rate_parceled_exfield,
              'folder' => work.folder,
              'initial_atendee' => work.initial_atendee,
              'note' => 'New description',
              'checklist' => work.checklist,
              'extra_pending_document' => work.extra_pending_document
            },
            'relationships' => {
              'jobs' => { 'data' => [] },
              'powers' => { 'data' => [] },
              'profile_customers' => { 'data' => [] },
              'offices' => { 'data' => [] }
            }
          }
        )
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
              'action' => work.action,
              'number' => work.number,
              'rate_percentage' => work.rate_percentage,
              'rate_percentage_exfield' => work.rate_percentage_exfield,
              'rate_fixed' => work.rate_fixed,
              'rate_parceled_exfield' => work.rate_parceled_exfield,
              'folder' => work.folder,
              'initial_atendee' => work.initial_atendee,
              'note' => work.note,
              'checklist' => work.checklist,
              'extra_pending_document' => work.extra_pending_document
            },
            'relationships' => {
              'jobs' => { 'data' => [] },
              'powers' => { 'data' => [] },
              'profile_customers' => { 'data' => [] },
              'offices' => { 'data' => [] }
            }
          },
          'included' => []
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
