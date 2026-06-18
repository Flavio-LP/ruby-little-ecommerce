require "rails_helper"

RSpec.describe "POST /:shop_slug/produtos/:id/add_to_cart", type: :request do
  it "rejects adding a product from a different shop than the one in context" do
    shop = create(:shop)
    other_shop = create(:shop)
    other_product = ActsAsTenant.with_tenant(other_shop) { create(:product, shop: other_shop) }

    post "/#{shop.slug}/produtos/#{other_product.id}/add_to_cart"

    expect(response).to have_http_status(:not_found)
  end
end
