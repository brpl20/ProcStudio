# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/draft/works', type: :request do
  let!(:admin) { create(:profile_admin).admin }

  let(:valid_attributes) { { name: 'Procuração Cliente XYZ', work_id: create(:work).id } }
  let(:invalid_attributes) { attributes_for(:draft_work, name: nil) }
  let(:valid_headers) { { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' } }

  describe 'GET /index' do
    it 'renders a successful response' do
      Draft::Work.create! valid_attributes
      get api_v1_draft_works_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      work = Draft::Work.create! valid_attributes
      get api_v1_draft_work_url(work), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Draft::Work' do
        expect do
          post api_v1_draft_works_url, params: { draft_work: valid_attributes.merge(name: Faker::Company.name) },
                                       headers: valid_headers, as: :json
        end.to change(Draft::Work, :count).by(1)
      end

      it 'renders a JSON response with the new draft_work' do
        post api_v1_draft_works_url,
             params: { draft_work: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Draft::Work' do
        expect do
          post api_v1_draft_works_url,
               params: { draft_work: invalid_attributes }, as: :json
        end.to change(Draft::Work, :count).by(0)
      end

      it 'renders a JSON response with errors for the new draft_work' do
        post api_v1_draft_works_url,
             params: { draft_work: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
        expect(response.parsed_body['name']).to include('não pode ficar em branco')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Procuração Cliente XYZ-2', work_id: Work.last.id } }

      it 'updates the requested draft_work' do
        work = Draft::Work.create! valid_attributes
        patch api_v1_draft_work_url(work),
              params: { draft_work: new_attributes }, headers: valid_headers, as: :json
        work.reload
        expect(work.name).to eq('Procuração Cliente XYZ-2')
      end

      it 'renders a JSON response with the draft_work' do
        work = Draft::Work.create! valid_attributes
        patch api_v1_draft_work_url(work),
              params: { draft_work: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the draft_work' do
        work = Draft::Work.create! valid_attributes
        patch api_v1_draft_work_url(work),
              params: { draft_work: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
        expect(response.parsed_body['name']).to include('não pode ficar em branco')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested draft_work' do
      work = Draft::Work.create! valid_attributes
      expect do
        delete api_v1_draft_work_url(work), headers: valid_headers, as: :json
      end.to change(Draft::Work, :count).by(-1)
    end
  end
end
