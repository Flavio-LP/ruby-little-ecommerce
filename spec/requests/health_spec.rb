require "rails_helper"

RSpec.describe "Health check", type: :request do
  describe "GET /up" do
    it "returns 200 when the app, database, and Redis are healthy" do
      get "/up"

      expect(response).to have_http_status(:ok)
    end

    it "returns a non-200 status when the database connection fails" do
      allow(ActiveRecord::Base).to receive(:connection).and_raise(ActiveRecord::ConnectionNotEstablished)

      get "/up"

      expect(response).to have_http_status(:service_unavailable)
    end

    it "does not require authentication" do
      get "/up"

      expect(response).not_to have_http_status(:unauthorized)
      expect(response).not_to redirect_to(%r{/users/sign_in})
    end
  end
end
