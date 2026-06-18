require "rails_helper"

RSpec.describe "Public::CartItems", type: :request do
  def add_product_to_cart(shop, product)
    post "/#{shop.slug}/produtos/#{product.id}/add_to_cart"
  end

  describe "PATCH /:shop_slug/cart/cart_items/:id" do
    it "updates the quantity and reflects the new total" do
      shop = create(:shop)
      product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, price_cents: 1_000) }
      add_product_to_cart(shop, product)
      cart_item = ActsAsTenant.with_tenant(shop) { CartItem.joins(:product).find_by!(product: product) }

      patch "/#{shop.slug}/cart/cart_items/#{cart_item.id}",
        params: { cart_item: { quantity: 3 } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("$30.00")
    end

    it "removes the item when quantity is set to 0" do
      shop = create(:shop)
      product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop) }
      add_product_to_cart(shop, product)
      cart_item = ActsAsTenant.with_tenant(shop) { CartItem.joins(:product).find_by!(product: product) }

      patch "/#{shop.slug}/cart/cart_items/#{cart_item.id}",
        params: { cart_item: { quantity: 0 } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("Your cart is empty")
    end
  end

  describe "DELETE /:shop_slug/cart/cart_items/:id" do
    it "removes the item and updates the total" do
      shop = create(:shop)
      product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop) }
      add_product_to_cart(shop, product)
      cart_item = ActsAsTenant.with_tenant(shop) { CartItem.joins(:product).find_by!(product: product) }

      delete "/#{shop.slug}/cart/cart_items/#{cart_item.id}",
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("Your cart is empty")
    end
  end
end
