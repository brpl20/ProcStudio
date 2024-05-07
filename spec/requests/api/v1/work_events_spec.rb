require 'rails_helper'

RSpec.describe "/api/v1/work_events", type: :request do
  let!(:admin) { create(:profile_admin).admin }
  let(:valid_headers) { { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' } }

  let(:work) { create(:work) }
  let(:valid_attributes) {
    {
      work_id: work.id,
      date: Time.now.to_fs(:db),
      description: 'Teste',
      status: 'in_progress'
    }
  }

  let(:invalid_attributes) {
    {
      work_id: nil,
      date: nil,
      description: 'A description'
    }
  }

  describe "GET /index" do
    it "renders a successful response" do
      WorkEvent.create! valid_attributes
      get api_v1_work_events_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      work_event = WorkEvent.create! valid_attributes
      get api_v1_work_event_url(work_event), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new WorkEvent" do
        expect {
          post api_v1_work_events_url,
               params: { work_event: valid_attributes }, headers: valid_headers, as: :json
        }.to change(WorkEvent, :count).by(1)
      end

      it "renders a JSON response with the new work_event" do
        post api_v1_work_events_url,
             params: { work_event: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new WorkEvent" do
        expect {
          post api_v1_work_events_url,
               params: { work_event: invalid_attributes }, as: :json
        }.to change(WorkEvent, :count).by(0)
      end

      it "renders a JSON response with errors for the new work_event" do
        post api_v1_work_events_url,
             params: { work_event: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested work_event" do
        work_event = WorkEvent.create! valid_attributes
        patch api_v1_work_event_url(work_event),
              params: { work_event: new_attributes }, headers: valid_headers, as: :json
        work_event.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the work_event" do
        work_event = WorkEvent.create! valid_attributes
        patch api_v1_work_event_url(work_event),
              params: { work_event: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the work_event" do
        work_event = WorkEvent.create! valid_attributes
        patch api_v1_work_event_url(work_event),
              params: { work_event: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested work_event" do
      work_event = WorkEvent.create! valid_attributes
      expect {
        delete api_v1_work_event_url(work_event), headers: valid_headers, as: :json
      }.to change(WorkEvent, :count).by(-1)
    end
  end
end
