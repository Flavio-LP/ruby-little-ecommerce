require 'rails_helper'

RSpec.describe Shop, type: :model do
  it "is valid with a name and a URL-safe slug" do
    shop = build(:shop)
    expect(shop).to be_valid
  end

  it "is not valid without a name" do
    shop = build(:shop, name: nil)
    expect(shop).not_to be_valid
  end

  it "is not valid with a duplicate slug" do
    create(:shop, slug: "acme")
    shop = build(:shop, slug: "acme")
    expect(shop).not_to be_valid
  end

  it "is not valid with a non-URL-safe slug" do
    shop = build(:shop, slug: "Acme Store!")
    expect(shop).not_to be_valid
  end
end
