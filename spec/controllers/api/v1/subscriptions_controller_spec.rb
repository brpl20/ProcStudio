# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SubscriptionsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:team) { create(:team, owner_admin: admin) }
  let!(:membership) { create(:team_membership, team: team, admin: admin, role: 'owner') }
  let(:subscription_plan) { create(:subscription_plan) }
  let!(:subscription) { create(:subscription, team: team, subscription_plan: subscription_plan) }
  
  before do
    allow(controller).to receive(:current_admin).and_return(admin)
    allow(controller).to receive(:current_team).and_return(team)
    allow(controller).to receive(:require_team!).and_return(true)
  end

  describe 'GET #show' do
    it 'returns the team subscription details' do
      get :show, params: { id: subscription.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(subscription.id)
      expect(json_response['subscription_plan']).to be_present
      expect(json_response['subscription_plan']['name']).to eq(subscription_plan.name)
    end

    it 'returns 404 when team has no subscription' do
      subscription.destroy
      
      get :show, params: { id: 999 }
      
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    let(:new_plan) { create(:subscription_plan, :premium) }
    let(:valid_params) do
      {
        subscription: {
          subscription_plan_id: new_plan.id
        }
      }
    end

    before do
      subscription.destroy # Remove existing subscription
    end

    context 'when admin is owner or admin' do
      it 'creates a new subscription' do
        expect {
          post :create, params: valid_params
        }.to change(Subscription, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['subscription_plan_id']).to eq(new_plan.id)
        expect(json_response['status']).to eq('trial') # Free plans would be 'active'
      end

      it 'sets status to active for free plans' do
        free_plan = create(:subscription_plan, :free)
        valid_params[:subscription][:subscription_plan_id] = free_plan.id
        
        post :create, params: valid_params
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('active')
      end
    end

    context 'when admin is member' do
      before do
        membership.update(role: 'member')
      end

      it 'returns forbidden' do
        post :create, params: valid_params
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: subscription.id,
        subscription: {
          status: 'active'
        }
      }
    end

    it 'updates the subscription' do
      patch :update, params: update_params
      
      expect(response).to have_http_status(:ok)
      subscription.reload
      expect(subscription.status).to eq('active')
    end
  end

  describe 'PATCH #cancel' do
    before do
      subscription.update(status: 'active')
    end

    it 'cancels the subscription' do
      patch :cancel, params: { id: subscription.id }
      
      expect(response).to have_http_status(:ok)
      subscription.reload
      expect(subscription.status).to eq('cancelled')
      expect(subscription.end_date).to eq(Date.current.end_of_month)
    end
  end

  describe 'GET #plans' do
    let!(:active_plan) { create(:subscription_plan) }
    let!(:inactive_plan) { create(:subscription_plan, :inactive) }

    it 'returns only active subscription plans' do
      get :plans
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      plan_ids = json_response.map { |p| p['id'] }
      expect(plan_ids).to include(active_plan.id)
      expect(plan_ids).not_to include(inactive_plan.id)
    end
  end

  describe 'GET #usage' do
    before do
      create_list(:office, 2, team: team)
      create(:admin) # This won't count as it's not in the team
      subscription.update(status: 'active')
    end

    it 'returns usage statistics for the team' do
      get :usage
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      
      expect(json_response['users']['used']).to eq(1) # Only the admin in the team
      expect(json_response['users']['limit']).to eq(subscription_plan.max_users)
      expect(json_response['offices']['used']).to eq(2)
      expect(json_response['offices']['limit']).to eq(subscription_plan.max_offices)
      expect(json_response['cases']['used']).to eq(0) # No works created yet
      expect(json_response['cases']['limit']).to eq(subscription_plan.max_cases)
    end

    it 'returns 404 when team has no subscription' do
      subscription.destroy
      
      get :usage
      
      expect(response).to have_http_status(:not_found)
    end
  end
end