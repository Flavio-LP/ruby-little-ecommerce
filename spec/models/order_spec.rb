require 'rails_helper'

RSpec.describe Order, type: :model do
  it "is scoped to a shop via acts_as_tenant" do
    shop = create(:shop)
    order = ActsAsTenant.with_tenant(shop) { create(:order, shop: shop) }
    expect(order.shop).to eq(shop)
  end

  it "defaults to pending status" do
    shop = create(:shop)
    order = ActsAsTenant.with_tenant(shop) { create(:order, shop: shop) }
    expect(order).to be_pending
  end
end
