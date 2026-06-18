require "rails_helper"

RSpec.describe Shops::Register do
  let(:valid_params) do
    {
      email: "seller@example.com",
      password: "password123",
      password_confirmation: "password123",
      shop_name: "Acme Store"
    }
  end

  it "creates a seller User and an associated Shop" do
    result = described_class.call(valid_params)

    expect(result).to be_success
    expect(result.user).to be_persisted
    expect(result.user).to be_seller
    expect(result.shop).to be_persisted
    expect(result.user.shop).to eq(result.shop)
  end

  it "derives a URL-safe slug from the shop name" do
    result = described_class.call(valid_params)

    expect(result.shop.slug).to eq("acme-store")
  end

  it "suffixes the slug when the base slug is already taken" do
    create(:shop, slug: "acme-store")

    result = described_class.call(valid_params)

    expect(result.shop.slug).to eq("acme-store-2")
  end

  it "rolls back the user when shop creation fails" do
    result = described_class.call(valid_params.merge(shop_name: ""))

    expect(result).to be_failure
    expect(User.exists?(email: "seller@example.com")).to be(false)
  end

  it "rolls back everything when the user is invalid" do
    result = described_class.call(valid_params.merge(password: "short", password_confirmation: "short"))

    expect(result).to be_failure
    expect(Shop.exists?(name: "Acme Store")).to be(false)
  end
end
