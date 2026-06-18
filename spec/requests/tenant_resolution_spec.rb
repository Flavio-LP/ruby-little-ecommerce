require "rails_helper"

RSpec.describe "Tenant resolution", type: :request do
  it "returns 404 for an unknown shop_slug" do
    get "/this-shop-does-not-exist/admin"

    expect(response).to have_http_status(:not_found)
  end
end
