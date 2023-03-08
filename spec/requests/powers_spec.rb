require 'rails_helper'

RSpec.describe "Powers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/powers/index"
      expect(response).to have_http_status(:success)
    end
  end

end
