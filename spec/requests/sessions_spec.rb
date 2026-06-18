require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /users/sign_in" do
    it "redirects a seller to their own shop's admin dashboard" do
      shop = create(:shop)
      seller = create(:user, :seller, shop: shop)

      post user_session_path, params: { user: { email: seller.email, password: "password123" } }

      expect(response).to redirect_to(admin_dashboard_path(shop_slug: shop.slug))
    end

    it "redirects a customer to the shop directory (root)" do
      customer = create(:user, role: :customer)

      post user_session_path, params: { user: { email: customer.email, password: "password123" } }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /users/sign_out" do
    it "redirects to the login screen instead of the shop directory" do
      customer = create(:user, role: :customer)
      sign_in customer

      delete destroy_user_session_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /" do
    it "lists all shops" do
      shop = create(:shop, name: "Acme")

      get root_path

      expect(response.body).to include("Acme")
      expect(response).to have_http_status(:ok)
    end
  end
end
