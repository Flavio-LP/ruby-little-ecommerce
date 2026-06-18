require 'rails_helper'

RSpec.describe CartItem, type: :model do
  it "is not valid with a zero or negative quantity" do
    item = build(:cart_item, quantity: 0)
    expect(item).not_to be_valid
  end

  it "computes its subtotal" do
    item = build(:cart_item, quantity: 3, unit_price_cents: 200)
    expect(item.subtotal_cents).to eq(600)
  end

  it "enforces one row per product per cart" do
    shop = create(:shop)
    cart = ActsAsTenant.with_tenant(shop) { create(:cart, shop: shop) }
    product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop) }
    create(:cart_item, cart: cart, product: product)

    duplicate = build(:cart_item, cart: cart, product: product)

    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
