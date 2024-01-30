# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::JobsController, type: :request do
  let!(:admin) { create(:profile_admin).admin }
  describe '#index' do
    let!(:job) { create(:job, :job_complete) }

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
              'status' => job.status,
              'customer' => "#{job.profile_customer.name} #{job.profile_customer.last_name}",
              'responsible' => job.profile_admin.name,
              'work_number' => job.work.number
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
    let(:profile_admin) { create(:profile_admin) }
    let(:profile_customer) { create(:profile_customer) }
    let(:work) { create(:work) }

    context 'when request is valid' do
      it 'returns :ok' do
        post '/api/v1/jobs', params: {
          job: {
            description: Faker::Lorem.sentence,
            deadline: Faker::Date.forward(days: 23),
            priority: 'low',
            society: Faker::Company.name,
            comment: Faker::Lorem.sentence,
            status: 'pending',
            profile_customer_id: profile_customer.id,
            profile_admin_id: profile_admin.id,
            work_id: work.id
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
    context 'when create tries to make an request without token' do
      it 'returns :unauthorized' do
        post '/api/v1/jobs', params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'update' do
    let!(:job) { create(:job, :job_complete, id: 5) }

    context 'when request is valid' do
      it 'returns :ok' do
        put '/api/v1/jobs/5', params: {
          job: {
            comment: 'This is a new comment'
          }
        }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
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
    let!(:job) { create(:job, :job_complete, id: 5) }
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
              'deadline' => job.deadline.strftime('%Y-%m-%d'),
              'status' => job.status,
              'priority' => job.priority,
              'comment' => job.comment,
              'customer' => "#{job.profile_customer.name} #{job.profile_customer.last_name}",
              'responsible' => job.profile_admin.name,
              'work_number' => job.work.number,
              'profile_admin_id' => job.profile_admin_id,
              'profile_customer' => {
                'id' => job.profile_customer.id,
                'customer_type' => job.profile_customer.customer_type,
                'name' => job.profile_customer.name,
                'last_name' => job.profile_customer.last_name,
                'gender' => job.profile_customer.gender,
                'rg' => job.profile_customer.rg,
                'cpf' => job.profile_customer.cpf,
                'cnpj' => job.profile_customer.cnpj,
                'nationality' => job.profile_customer.nationality,
                'civil_status' => job.profile_customer.civil_status,
                'capacity' => job.profile_customer.capacity,
                'profession' => job.profile_customer.profession,
                'company' => job.profile_customer.company,
                'birth' => job.profile_customer.birth.to_json,
                'mother_name' => job.profile_customer.mother_name,
                'number_benefit' => job.profile_customer.number_benefit,
                'status' => job.profile_customer.status,
                'document' => job.profile_customer.document,
                'nit' => job.profile_customer.nit,
                'inss_password' => job.profile_customer.inss_password,
                'invalid_person' => job.profile_customer.invalid_person,
                'customer_id' => job.profile_customer.customer_id
              },
              'work' => {
                'id' => job.work.id,
                'procedure' => job.work.procedure,
                'subject' => job.work.subject,
                'number' => job.work.number,
                'rate_parceled_exfield' => job.work.rate_parceled_exfield,
                'folder' => job.work.folder,
                'initial_atendee' => job.work.initial_atendee,
                'note' => job.work.note,
                'extra_pending_document' => job.work.extra_pending_document,
                'created_at' => job.work.created_at.iso8601,
                'updated_at' => job.work.updated_at.iso8601,
                'civel_area' => job.work.civel_area,
                'social_security_areas' => job.work.social_security_areas,
                'laborite_areas' => job.work.laborite_areas,
                'tributary_areas' => job.work.tributary_areas,
                'other_description' => job.work.other_description,
                'compensations_five_years' => job.work.compensations_five_years,
                'compensations_service' => job.work.compensations_service,
                'lawsuit' => job.work.lawsuit,
                'gain_projection' => job.work.gain_projection
              }
            }
          }
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
