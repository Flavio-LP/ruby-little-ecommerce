require "rails_helper"

RSpec.describe "Admin::Products", type: :request do
  describe "cross-tenant access" do
    it "does not allow editing another shop's product" do
      shop = create(:shop)
      other_shop = create(:shop)
      other_product = ActsAsTenant.with_tenant(other_shop) { create(:product, shop: other_shop) }
      seller = create(:user, :seller, shop: shop)
      sign_in seller

      get "/#{shop.slug}/admin/products/#{other_product.id}/edit"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "creating a product" do
    it "scopes the new product to the seller's own shop" do
      shop = create(:shop)
      seller = create(:user, :seller, shop: shop)
      sign_in seller

      post "/#{shop.slug}/admin/products", params: {
        product: { name: "Widget", price_cents: 500 }
      }

      expect(response).to redirect_to("/#{shop.slug}/admin/products")
      expect(Product.unscoped.find_by(name: "Widget").shop_id).to eq(shop.id)
    end
  end
end
