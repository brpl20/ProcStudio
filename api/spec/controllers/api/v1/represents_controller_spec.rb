# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RepresentsController, type: :controller do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team) }
  let(:customer1) { create(:customer, teams: [team]) }
  let(:customer2) { create(:customer, teams: [team]) }

  # Unable person (child)
  let(:unable_person) do
    create(:profile_customer,
           customer: customer1,
           capacity: 'unable',
           birth: 10.years.ago)
  end

  # Able person (adult/representative)
  let(:representor) do
    create(:profile_customer,
           customer: customer2,
           capacity: 'able',
           birth: 30.years.ago,
           profession: 'Teacher')
  end

  let(:valid_attributes) do
    {
      profile_customer_id: unable_person.id,
      representor_id: representor.id,
      relationship_type: 'representation',
      active: true,
      notes: 'Mother of the child'
    }
  end

  let(:invalid_attributes) do
    {
      profile_customer_id: unable_person.id,
      representor_id: nil, # Missing representor
      relationship_type: 'representation'
    }
  end

  before do
    sign_in user
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_team).and_return(team)
  end

  describe 'GET #index' do
    let!(:represent) { create(:represent, valid_attributes.merge(team: team)) }

    context 'when fetching all represents for the team' do
      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
        expect(response.parsed_body['success']).to be true
      end

      it 'returns the represents' do
        get :index
        data = response.parsed_body['data']
        expect(data.size).to eq(1)
        expect(data.first['id']).to eq(represent.id)
      end
    end

    context 'when fetching represents for a specific customer' do
      it 'returns only represents for that customer' do
        other_customer = create(:profile_customer, customer: create(:customer, teams: [team]))
        create(:represent,
               profile_customer: other_customer,
               representor: representor,
               team: team)

        get :index, params: { profile_customer_id: unable_person.id }

        data = response.parsed_body['data']
        expect(data.size).to eq(1)
        expect(data.first['profile_customer_id']).to eq(unable_person.id)
      end
    end

    context 'with filters' do
      it 'filters by active status' do
        inactive_represent = create(:represent,
                                    profile_customer: unable_person,
                                    representor: create(:profile_customer, capacity: 'able'),
                                    team: team,
                                    active: false)

        get :index, params: { active: 'true' }

        data = response.parsed_body['data']
        expect(data.pluck('id')).to include(represent.id)
        expect(data.pluck('id')).not_to include(inactive_represent.id)
      end

      it 'filters by relationship type' do
        assistance_represent = create(:represent,
                                      profile_customer: unable_person,
                                      representor: create(:profile_customer, capacity: 'able'),
                                      team: team,
                                      relationship_type: 'assistance')

        get :index, params: { relationship_type: 'representation' }

        data = response.parsed_body['data']
        expect(data.pluck('id')).to include(represent.id)
        expect(data.pluck('id')).not_to include(assistance_represent.id)
      end
    end
  end

  describe 'GET #show' do
    let!(:represent) { create(:represent, valid_attributes.merge(team: team)) }

    it 'returns a successful response' do
      get :show, params: { id: represent.id }
      expect(response).to be_successful
    end

    it 'returns detailed information' do
      get :show, params: { id: represent.id }

      data = response.parsed_body['data']
      expect(data['id']).to eq(represent.id)
      expect(data['profile_customer']).to be_present
      expect(data['representor']).to be_present
    end

    it 'returns not found for represents from other teams' do
      other_team = create(:team)
      other_represent = create(:represent, team: other_team)

      get :show, params: { id: other_represent.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Represent' do
        expect do
          post :create, params: { represent: valid_attributes }
        end.to change(Represent, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: { represent: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.parsed_body['success']).to be true
      end

      it 'allows multiple representors for the same customer' do
        # Create first representor
        post :create, params: { represent: valid_attributes }
        expect(response).to have_http_status(:created)

        # Create second representor (father)
        second_representor = create(:profile_customer,
                                    customer: create(:customer, teams: [team]),
                                    capacity: 'able',
                                    profession: 'Engineer')

        second_attributes = valid_attributes.merge(
          representor_id: second_representor.id,
          notes: 'Father of the child'
        )

        expect do
          post :create, params: { represent: second_attributes }
        end.to change(Represent, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Represent' do
        expect do
          post :create, params: { represent: invalid_attributes }
        end.not_to change(Represent, :count)
      end

      it 'returns an unprocessable entity status' do
        post :create, params: { represent: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['success']).to be false
      end

      it 'prevents self-representation' do
        post :create, params: {
          represent: {
            profile_customer_id: representor.id,
            representor_id: representor.id,
            relationship_type: 'representation'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        errors = response.parsed_body['errors']
        expect(errors.join).to include('não pode representar a si mesmo')
      end

      it 'requires representor to be legally capable' do
        incapable_representor = create(:profile_customer,
                                       customer: create(:customer, teams: [team]),
                                       capacity: 'unable',
                                       birth: 12.years.ago)

        post :create, params: {
          represent: {
            profile_customer_id: unable_person.id,
            representor_id: incapable_representor.id,
            relationship_type: 'representation'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        errors = response.parsed_body['errors']
        expect(errors.join).to include('deve ser legalmente capaz')
      end
    end
  end

  describe 'PATCH #update' do
    let!(:represent) { create(:represent, valid_attributes.merge(team: team)) }

    context 'with valid parameters' do
      it 'updates the represent' do
        patch :update, params: {
          id: represent.id,
          represent: { notes: 'Updated notes' }
        }

        expect(response).to be_successful
        represent.reload
        expect(represent.notes).to eq('Updated notes')
      end
    end

    context 'with invalid parameters' do
      it 'returns an unprocessable entity status' do
        patch :update, params: {
          id: represent.id,
          represent: { representor_id: nil }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:represent) { create(:represent, valid_attributes.merge(team: team)) }

    it 'destroys the represent' do
      expect do
        delete :destroy, params: { id: represent.id }
      end.to change(Represent, :count).by(-1)
    end

    it 'returns a successful response' do
      delete :destroy, params: { id: represent.id }
      expect(response).to be_successful
      expect(response.parsed_body['success']).to be true
    end
  end

  describe 'POST #deactivate' do
    let!(:represent) { create(:represent, valid_attributes.merge(team: team, active: true)) }

    it 'deactivates the represent' do
      post :deactivate, params: { id: represent.id }

      expect(response).to be_successful
      represent.reload
      expect(represent.active).to be false
      expect(represent.end_date).to eq(Date.current)
    end
  end

  describe 'POST #reactivate' do
    let!(:represent) do
      create(:represent,
             valid_attributes.merge(team: team, active: false, end_date: 1.day.ago))
    end

    it 'reactivates the represent' do
      post :reactivate, params: { id: represent.id }

      expect(response).to be_successful
      represent.reload
      expect(represent.active).to be true
      expect(represent.end_date).to be_nil
    end
  end

  describe 'GET #by_representor' do
    let!(:represent1) do
      create(:represent,
             profile_customer: unable_person,
             representor: representor,
             team: team)
    end

    let!(:represent2) do
      create(:represent,
             profile_customer: create(:profile_customer, capacity: 'unable'),
             representor: representor,
             team: team)
    end

    it 'returns all customers represented by a person' do
      get :by_representor, params: { representor_id: representor.id }

      expect(response).to be_successful
      data = response.parsed_body['data']
      expect(data.size).to eq(2)
      expect(data.pluck('representor_id').uniq).to eq([representor.id])
    end
  end
end
