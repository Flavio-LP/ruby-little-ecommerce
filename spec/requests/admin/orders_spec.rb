require "rails_helper"

RSpec.describe "Admin::Orders", type: :request do
  describe "GET /:shop_slug/admin/orders" do
    it "lists only orders for the current shop" do
      shop = create(:shop)
      other_shop = create(:shop)
      order = ActsAsTenant.with_tenant(shop) { create(:order, shop: shop) }
      ActsAsTenant.with_tenant(other_shop) { create(:order, shop: other_shop) }
      seller = create(:user, :seller, shop: shop)
      sign_in seller

      get "/#{shop.slug}/admin/orders"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(admin_order_path(shop_slug: shop.slug, id: order.id))
    end
  end

  describe "GET /:shop_slug/admin/orders/:id" do
    it "denies access to another shop's order with 404" do
      shop = create(:shop)
      other_shop = create(:shop)
      other_order = ActsAsTenant.with_tenant(other_shop) { create(:order, shop: other_shop) }
      seller = create(:user, :seller, shop: shop)
      sign_in seller

      get "/#{shop.slug}/admin/orders/#{other_order.id}"

      expect(response).to have_http_status(:not_found)
    end
  end
end
