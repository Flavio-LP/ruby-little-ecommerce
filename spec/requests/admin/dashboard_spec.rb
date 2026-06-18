require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  describe "GET /:shop_slug/admin" do
    it "redirects to sign in when not authenticated" do
      shop = create(:shop)

      get "/#{shop.slug}/admin"

      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders the dashboard for the shop's own seller" do
      shop = create(:shop)
      seller = create(:user, :seller, shop: shop)
      sign_in seller

      get "/#{shop.slug}/admin"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(shop.name)
    end

    it "denies access to another shop's seller with 403" do
      shop = create(:shop)
      other_seller = create(:user, :seller)
      sign_in other_seller

      get "/#{shop.slug}/admin"

      expect(response).to have_http_status(:found)
      expect(flash[:alert]).to be_present
    end
  end
end
