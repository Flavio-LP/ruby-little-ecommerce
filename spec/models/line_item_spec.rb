require 'rails_helper'

RSpec.describe LineItem, type: :model do
  it "computes its subtotal" do
    item = build(:line_item, quantity: 2, unit_price_cents: 500)
    expect(item.subtotal_cents).to eq(1_000)
  end

  it "keeps its stored unit_price_cents even after the product's price changes" do
    shop = create(:shop)
    product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, price_cents: 1_000) }
    line_item = create(:line_item, shop: shop, product: product, unit_price_cents: 1_000)

    product.update!(price_cents: 5_000)

    expect(line_item.reload.unit_price_cents).to eq(1_000)
  end
end
