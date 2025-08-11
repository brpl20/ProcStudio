require 'rails_helper'

RSpec.describe "Api::V1::SuperAdmin::Dashboards", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/super_admin/dashboard/index"
      expect(response).to have_http_status(:success)
    end
  end

end
