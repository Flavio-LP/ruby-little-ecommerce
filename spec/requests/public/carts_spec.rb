require "rails_helper"

RSpec.describe "Public::Carts", type: :request do
  describe "GET /:shop_slug/cart" do
    it "shows an empty-state message for an empty cart" do
      shop = create(:shop)

      get "/#{shop.slug}/cart"

      expect(response.body).to include("Your cart is empty")
    end

    it "shows items, subtotals, and the grand total" do
      shop = create(:shop)
      product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, name: "Widget", price_cents: 1_000) }
      post "/#{shop.slug}/produtos/#{product.id}/add_to_cart"

      get "/#{shop.slug}/cart"

      expect(response.body).to include("Widget")
      expect(response.body).to include("$10.00")
    end
  end
end
