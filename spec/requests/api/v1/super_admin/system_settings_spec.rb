require 'rails_helper'

RSpec.describe "Api::V1::SuperAdmin::SystemSettings", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/super_admin/system_settings/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/api/v1/super_admin/system_settings/update"
      expect(response).to have_http_status(:success)
    end
  end

end
