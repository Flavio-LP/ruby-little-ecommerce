require "rails_helper"

RSpec.describe "POST /:shop_slug/produtos/:id/add_to_cart (Turbo Stream)", type: :request do
  it "returns a turbo-stream response that replaces the cart_count frame with the updated count" do
    shop = create(:shop)
    product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, name: "Widget") }

    post "/#{shop.slug}/produtos/#{product.id}/add_to_cart",
      headers: { "Accept" => "text/vnd.turbo-stream.html" }

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    expect(response.body).to include('turbo-stream action="replace" target="cart_count"')
    expect(response.body).to include("Cart (1)")
  end

  it "increments the count on a second add for the same product, in the same turbo-stream response" do
    shop = create(:shop)
    product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop) }
    headers = { "Accept" => "text/vnd.turbo-stream.html" }

    post "/#{shop.slug}/produtos/#{product.id}/add_to_cart", headers: headers
    post "/#{shop.slug}/produtos/#{product.id}/add_to_cart", headers: headers

    expect(response.body).to include("Cart (2)")
  end
end
