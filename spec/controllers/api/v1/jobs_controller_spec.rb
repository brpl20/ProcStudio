# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::JobsController, type: :request do
  let!(:admin) { create(:admin) }
  describe '#index' do
    let!(:job) { create(:job) }

    context 'when request is valid' do
      before do
        get '/api/v1/jobs', headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end
      it 'returns all jobs' do
        expect(JSON.parse(response.body)).to eq(
          'data' => [{
            'id' => job.id.to_s,
            'type' => 'job',
            'attributes' => {
              'description' => job.description,
              'deadline' => job.deadline.iso8601,
              'priority' => job.priority,
              'comment' => job.comment,
              'status' => job.status
            },
            'relationships' => {
              'works' => {
                'data' => []
              }
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
        get '/api/v1/jobs', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'create' do
    let(:customer) { create(:customer) }
    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/jobs', params: {
          job: {
            description: Faker::Lorem.sentence,
            deadline: Faker::Date.forward(days: 23),
            priority: 'low',
            society: Faker::Company.name,
            comment: Faker::Lorem.sentence,
            status: 'pending'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:created)
      end
    end
    context 'when create tries to make an request without token' do
      it 'returns :unauthorized' do
        post '/api/v1/jobs', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'update' do
    let!(:job) { create(:job, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        put '/api/v1/jobs/5', params: {
          job: {
            comment: 'This is a new comment'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => job.id.to_s,
            'type' => 'job',
            'attributes' => {
              'description' => job.description,
              'deadline' => job.deadline.iso8601,
              'priority' => job.priority,
              'comment' => 'This is a new comment',
              'status' => job.status
            },
            'relationships' => {
              'works' => {
                'data' => []
              }
            }
          }
        )
      end
    end
    context 'when update tries to make an request without token' do
      it 'returns :unauthorized' do
        put '/api/v1/jobs/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'show' do
    let!(:job) { create(:job, id: 5) }
    context 'when request is valid' do
      it 'returns :ok' do
        get '/api/v1/jobs/5',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'id' => job.id.to_s,
            'type' => 'job',
            'attributes' => {
              'description' => job.description,
              'deadline' => job.deadline.iso8601,
              'priority' => job.priority,
              'comment' => job.comment,
              'status' => job.status
            },
            'relationships' => {
              'works' => {
                'data' => []
              }
            }
          }, 'included' => []
        )
      end
    end
    context 'when show tries to make an request without token' do
      it 'returns :unauthorized' do
        get '/api/v1/jobs/5', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when job dont exists' do
      it 'returns :not_found' do
        get '/api/v1/jobs/35',
            headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end