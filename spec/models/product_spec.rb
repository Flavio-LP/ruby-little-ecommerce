require 'rails_helper'

RSpec.describe Product, type: :model do
  it "is valid with a name and a positive price" do
    shop = create(:shop)
    product = ActsAsTenant.with_tenant(shop) { build(:product, shop: shop) }
    expect(product).to be_valid
  end

  it "is not valid with a zero or negative price" do
    shop = create(:shop)
    product = ActsAsTenant.with_tenant(shop) { build(:product, shop: shop, price_cents: 0) }
    expect(product).not_to be_valid
  end

  it "scopes Product.all to the current tenant" do
    shop_a = create(:shop)
    shop_b = create(:shop)
    product_a = ActsAsTenant.with_tenant(shop_a) { create(:product, shop: shop_a) }
    ActsAsTenant.with_tenant(shop_b) { create(:product, shop: shop_b) }

    result = ActsAsTenant.with_tenant(shop_a) { Product.all }

    expect(result).to contain_exactly(product_a)
  end
end
