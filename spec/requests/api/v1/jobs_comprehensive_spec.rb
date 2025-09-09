# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Jobs Comprehensive', type: :request do
  # Create user3 for testing
  let(:user3) do
    User.find_or_create_by(email: 'u3@gmail.com') do |user|
      user.password = '123456'
      user.status = 'active'
      user.team_id = 46
    end
  end

  let(:user3_profile) do
    UserProfile.find_or_create_by(user: user3) do |profile|
      profile.name = 'Dayeni'
      profile.last_name = 'Oliveira'
      profile.role = 'lawyer'
      profile.oab = 'PR_54161'
    end
  end

  # Create additional users in the same team for testing assignees, supervisors, collaborators
  let(:user_assignee) do
    User.find_or_create_by(email: 'assignee_test@gmail.com') do |user|
      user.password = '123456'
      user.status = 'active'
      user.team_id = 46
    end
  end

  let(:assignee_profile) do
    UserProfile.find_or_create_by(user: user_assignee) do |profile|
      profile.name = 'John'
      profile.last_name = 'Assignee'
      profile.role = 'lawyer'
    end
  end

  let(:user_supervisor) do
    User.find_or_create_by(email: 'supervisor_test@gmail.com') do |user|
      user.password = '123456'
      user.status = 'active'
      user.team_id = 46
    end
  end

  let(:supervisor_profile) do
    UserProfile.find_or_create_by(user: user_supervisor) do |profile|
      profile.name = 'Jane'
      profile.last_name = 'Supervisor'
      profile.role = 'lawyer'
    end
  end

  let(:user_collaborator) do
    User.find_or_create_by(email: 'collaborator_test@gmail.com') do |user|
      user.password = '123456'
      user.status = 'active'
      user.team_id = 46
    end
  end

  let(:collaborator_profile) do
    UserProfile.find_or_create_by(user: user_collaborator) do |profile|
      profile.name = 'Bob'
      profile.last_name = 'Collaborator'
      profile.role = 'paralegal'
    end
  end

  # Create a team
  let(:team) do
    Team.find_or_create_by(id: 46, name: 'Escritório Dayeni Cristina De Oliveira',
                           subdomain: 'dayeni-cristina-de-oliveira7')
  end

  # Create a customer
  let(:customer) do
    customer = create(:customer)
    customer.teams << team
    customer
  end

  let(:profile_customer) do
    create(:profile_customer,
           customer: customer,
           name: 'Cliente',
           last_name: 'Teste',
           cpf: '11111111111',
           rg: '123456789',
           gender: 'male',
           nationality: 'brazilian',
           civil_status: 'single',
           capacity: 'able')
  end

  # Create a work
  let(:work) { create(:work, team: team, number: 'WORK-2025-001') }

  # Headers with authentication token
  let(:auth_headers) do
    {
      'Authorization' => "Bearer #{user3.jwt_token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  before do
    # Ensure all data is created
    team
    user3
    user3_profile
    user_assignee
    assignee_profile
    user_supervisor
    supervisor_profile
    user_collaborator
    collaborator_profile
    profile_customer
    work
  end

  describe 'POST /api/v1/jobs - Create job with all fields' do
    let(:job_params) do
      {
        job: {
          description: 'Revisar contrato de prestação de serviços',
          deadline: '2025-01-30',
          status: 'pending',
          priority: 'high',
          comment: 'Cliente solicitou urgência na revisão',
          assignee_ids: [assignee_profile.id, user3_profile.id],
          supervisor_ids: [supervisor_profile.id],
          collaborator_ids: [collaborator_profile.id],
          profile_customer_id: profile_customer.id,
          work_id: work.id
        }
      }
    end

    it 'creates a job with all assignees, supervisors, and collaborators' do
      expect do
        post '/api/v1/jobs', params: job_params.to_json, headers: auth_headers
      end.to change(Job, :count).by(1)

      expect(response).to have_http_status(:created)

      json_response = response.parsed_body
      expect(json_response['success']).to be true
      expect(json_response['message']).to eq('Job criado com sucesso')

      data = json_response['data']
      attributes = data['attributes']

      # Verify basic attributes
      expect(attributes['description']).to eq('Revisar contrato de prestação de serviços')
      expect(attributes['deadline']).to eq('2025-01-30')
      expect(attributes['status']).to eq('pending')
      expect(attributes['priority']).to eq('high')
      expect(attributes['comment']).to eq('Cliente solicitou urgência na revisão')

      # Verify IDs are returned as numbers
      expect(attributes['customer_id']).to eq(profile_customer.id)
      expect(attributes['responsible_id']).to be_in([assignee_profile.id, user3_profile.id])
      expect(attributes['work_number']).to eq('WORK-2025-001')
      expect(attributes['created_by_id']).to eq(user3.id)

      # Verify arrays of IDs
      expect(attributes['assignee_ids']).to match_array([assignee_profile.id, user3_profile.id])
      expect(attributes['supervisor_ids']).to match_array([supervisor_profile.id])
      expect(attributes['collaborator_ids']).to match_array([collaborator_profile.id])

      # Verify the job was created with correct associations
      job = Job.last
      expect(job.assignees.pluck(:id)).to match_array([assignee_profile.id, user3_profile.id])
      expect(job.supervisors.pluck(:id)).to match_array([supervisor_profile.id])
      expect(job.job_user_profiles.where(role: 'collaborator').pluck(:user_profile_id)).to match_array([collaborator_profile.id])
    end
  end

  describe 'GET /api/v1/jobs/:id - Show job with detailed information' do
    let!(:job) do
      job = Job.create!(
        description: 'Job com todos os campos',
        deadline: Date.tomorrow,
        status: 'pending',
        priority: 'medium',
        comment: 'Comentário de teste',
        team: team,
        created_by: user3,
        profile_customer: profile_customer,
        work: work
      )

      # Add assignees, supervisors, and collaborators
      job.job_user_profiles.create!(user_profile: assignee_profile, role: 'assignee')
      job.job_user_profiles.create!(user_profile: user3_profile, role: 'assignee')
      job.job_user_profiles.create!(user_profile: supervisor_profile, role: 'supervisor')
      job.job_user_profiles.create!(user_profile: collaborator_profile, role: 'collaborator')

      job
    end

    it 'returns job with all detailed information including assignees, supervisors, and collaborators' do
      get "/api/v1/jobs/#{job.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)

      json_response = response.parsed_body
      expect(json_response['success']).to be true

      data = json_response['data']
      attributes = data['attributes']

      # Verify basic attributes
      expect(attributes['description']).to eq('Job com todos os campos')
      expect(attributes['status']).to eq('pending')
      expect(attributes['priority']).to eq('medium')

      # Verify IDs
      expect(attributes['customer_id']).to eq(profile_customer.id)
      expect(attributes['responsible_id']).to be_in([assignee_profile.id, user3_profile.id])
      expect(attributes['created_by_id']).to eq(user3.id)

      # Verify arrays of IDs (always present)
      expect(attributes['assignee_ids']).to match_array([assignee_profile.id, user3_profile.id])
      expect(attributes['supervisor_ids']).to match_array([supervisor_profile.id])
      expect(attributes['collaborator_ids']).to match_array([collaborator_profile.id])

      # Verify detailed assignees information (only in show action)
      assignees = attributes['assignees']
      expect(assignees).to be_an(Array)
      expect(assignees.size).to eq(2)

      assignee_data = assignees.find { |a| a['id'] == assignee_profile.id }
      expect(assignee_data).to include(
        'id' => assignee_profile.id,
        'name' => 'John',
        'last_name' => 'Assignee',
        'role' => 'assignee'
      )

      # Verify detailed supervisors information (only in show action)
      supervisors = attributes['supervisors']
      expect(supervisors).to be_an(Array)
      expect(supervisors.size).to eq(1)
      expect(supervisors.first).to include(
        'id' => supervisor_profile.id,
        'name' => 'Jane',
        'last_name' => 'Supervisor',
        'role' => 'supervisor'
      )

      # Verify detailed collaborators information (only in show action)
      collaborators = attributes['collaborators']
      expect(collaborators).to be_an(Array)
      expect(collaborators.size).to eq(1)
      expect(collaborators.first).to include(
        'id' => collaborator_profile.id,
        'name' => 'Bob',
        'last_name' => 'Collaborator',
        'role' => 'collaborator'
      )

      # Verify profile_customer details (only in show action)
      expect(attributes['profile_customer']).to be_present
      expect(attributes['profile_customer']['id']).to eq(profile_customer.id)
      expect(attributes['profile_customer']['name']).to eq('Cliente')
      expect(attributes['profile_customer']['last_name']).to eq('Teste')

      # Verify work details (only in show action)
      expect(attributes['work']).to be_present
      expect(attributes['work']['id']).to eq(work.id)
      expect(attributes['work']['number']).to eq('WORK-2025-001')
    end
  end

  describe 'GET /api/v1/jobs - List jobs with basic information' do
    let!(:job) do
      job = Job.create!(
        description: 'Job para listagem',
        deadline: Date.tomorrow,
        status: 'pending',
        priority: 'low',
        team: team,
        created_by: user3,
        profile_customer: profile_customer
      )

      job.job_user_profiles.create!(user_profile: assignee_profile, role: 'assignee')
      job.job_user_profiles.create!(user_profile: supervisor_profile, role: 'supervisor')

      job
    end

    it 'returns jobs with IDs instead of names' do
      get '/api/v1/jobs', headers: auth_headers

      expect(response).to have_http_status(:ok)

      json_response = response.parsed_body
      expect(json_response['success']).to be true

      data = json_response['data']
      expect(data).to be_an(Array)
      expect(data.size).to be >= 1

      job_data = data.find { |d| d['id'] == job.id.to_s }
      attributes = job_data['attributes']

      # In index action, we get IDs not detailed objects
      expect(attributes['customer_id']).to eq(profile_customer.id)
      expect(attributes['responsible_id']).to eq(assignee_profile.id)
      expect(attributes['assignee_ids']).to include(assignee_profile.id)
      expect(attributes['supervisor_ids']).to include(supervisor_profile.id)

      # These detailed fields should NOT be present in index
      expect(attributes['assignees']).to be_nil
      expect(attributes['supervisors']).to be_nil
      expect(attributes['collaborators']).to be_nil
      expect(attributes['profile_customer']).to be_nil
      expect(attributes['work']).to be_nil
    end
  end

  describe 'PUT /api/v1/jobs/:id - Update job with new assignees' do
    let!(:job) do
      job = Job.create!(
        description: 'Job para atualizar',
        deadline: Date.tomorrow,
        status: 'pending',
        priority: 'low',
        team: team,
        created_by: user3
      )

      job.job_user_profiles.create!(user_profile: assignee_profile, role: 'assignee')
      job
    end

    it 'updates job assignees, supervisors, and collaborators' do
      update_params = {
        job: {
          description: 'Job atualizado',
          assignee_ids: [user3_profile.id], # Replace assignee
          supervisor_ids: [supervisor_profile.id], # Add supervisor
          collaborator_ids: [collaborator_profile.id] # Add collaborator
        }
      }

      put "/api/v1/jobs/#{job.id}", params: update_params.to_json, headers: auth_headers

      expect(response).to have_http_status(:ok)

      json_response = response.parsed_body
      expect(json_response['success']).to be true

      attributes = json_response['data']['attributes']
      expect(attributes['description']).to eq('Job atualizado')
      expect(attributes['assignee_ids']).to eq([user3_profile.id])
      expect(attributes['supervisor_ids']).to eq([supervisor_profile.id])
      expect(attributes['collaborator_ids']).to eq([collaborator_profile.id])

      # Verify database was updated
      job.reload
      expect(job.assignees.pluck(:id)).to eq([user3_profile.id])
      expect(job.supervisors.pluck(:id)).to eq([supervisor_profile.id])
      expect(job.job_user_profiles.where(role: 'collaborator').pluck(:user_profile_id)).to eq([collaborator_profile.id])
    end
  end
end
