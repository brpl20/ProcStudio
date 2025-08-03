# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TeamsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:team) { create(:team, owner_admin: admin) }
  let!(:membership) { create(:team_membership, team: team, admin: admin, role: 'owner') }
  
  before do
    allow(controller).to receive(:current_admin).and_return(admin)
    allow(controller).to receive(:current_team).and_return(team)
    allow(controller).to receive(:require_team!).and_return(true)
  end

  describe 'GET #index' do
    let!(:other_team) { create(:team) }
    let!(:other_membership) { create(:team_membership, team: other_team, admin: admin, role: 'member') }

    it 'returns teams that the admin belongs to' do
      get :index
      
      expect(response).to have_http_status(:ok)
      team_ids = JSON.parse(response.body).map { |t| t['id'] }
      expect(team_ids).to include(team.id, other_team.id)
    end
  end

  describe 'GET #show' do
    it 'returns the team details' do
      get :show, params: { id: team.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(team.id)
      expect(json_response['name']).to eq(team.name)
    end

    it 'returns 404 for non-existent team' do
      get :show, params: { id: 999 }
      
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        team: {
          name: 'New Team',
          subdomain: 'newteam',
          description: 'A new team'
        }
      }
    end

    it 'creates a new team with valid parameters' do
      expect {
        post :create, params: valid_params
      }.to change(Team, :count).by(1)
      
      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['name']).to eq('New Team')
      expect(json_response['subdomain']).to eq('newteam')
    end

    it 'creates team membership for the creator' do
      expect {
        post :create, params: valid_params
      }.to change(TeamMembership, :count).by(1)
      
      new_team = Team.last
      membership = new_team.team_memberships.first
      expect(membership.admin).to eq(admin)
      expect(membership.role).to eq('owner')
    end

    it 'returns errors with invalid parameters' do
      invalid_params = { team: { name: '' } }
      
      post :create, params: invalid_params
      
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to be_present
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: team.id,
        team: {
          name: 'Updated Team Name',
          description: 'Updated description'
        }
      }
    end

    context 'when admin is owner' do
      it 'updates the team' do
        patch :update, params: update_params
        
        expect(response).to have_http_status(:ok)
        team.reload
        expect(team.name).to eq('Updated Team Name')
      end
    end

    context 'when admin is not owner or admin' do
      before do
        membership.update(role: 'member')
      end

      it 'returns forbidden' do
        patch :update, params: update_params
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when admin is owner' do
      it 'destroys the team' do
        expect {
          delete :destroy, params: { id: team.id }
        }.to change(Team, :count).by(-1)
        
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when admin is not owner' do
      before do
        membership.update(role: 'admin')
      end

      it 'allows admin to destroy' do
        expect {
          delete :destroy, params: { id: team.id }
        }.to change(Team, :count).by(-1)
      end
    end

    context 'when admin is member' do
      before do
        membership.update(role: 'member')
      end

      it 'returns forbidden' do
        delete :destroy, params: { id: team.id }
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #add_member' do
    let(:new_admin) { create(:admin, email: 'newmember@example.com') }
    let(:member_params) do
      {
        id: team.id,
        member: {
          email: new_admin.email,
          role: 'member'
        }
      }
    end

    context 'when admin has management rights' do
      it 'adds a new member to the team' do
        expect {
          post :add_member, params: member_params
        }.to change(TeamMembership, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['admin_id']).to eq(new_admin.id)
        expect(json_response['role']).to eq('member')
      end
    end

    context 'when admin email does not exist' do
      it 'returns not found' do
        member_params[:member][:email] = 'nonexistent@example.com'
        
        post :add_member, params: member_params
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #remove_member' do
    let(:member_admin) { create(:admin) }
    let!(:member_membership) { create(:team_membership, team: team, admin: member_admin, role: 'member') }

    it 'removes the member from the team' do
      expect {
        delete :remove_member, params: { id: team.id, admin_id: member_admin.id }
      }.to change(TeamMembership, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end

    it 'prevents removing the team owner' do
      delete :remove_member, params: { id: team.id, admin_id: admin.id }
      
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to include('Cannot remove team owner')
    end
  end

  describe 'PATCH #update_member' do
    let(:member_admin) { create(:admin) }
    let!(:member_membership) { create(:team_membership, team: team, admin: member_admin, role: 'member') }

    it 'updates the member role' do
      patch :update_member, params: { 
        id: team.id, 
        admin_id: member_admin.id,
        member: { role: 'admin' }
      }
      
      expect(response).to have_http_status(:ok)
      member_membership.reload
      expect(member_membership.role).to eq('admin')
    end
  end
end