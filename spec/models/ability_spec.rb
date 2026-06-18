require "rails_helper"

RSpec.describe Ability do
  describe "seller" do
    it "can manage their own shop" do
      shop = create(:shop)
      seller = create(:user, :seller, shop: shop)

      ability = Ability.new(seller)

      expect(ability).to be_able_to(:manage, shop)
    end

    it "cannot manage a different shop" do
      seller = create(:user, :seller)
      other_shop = create(:shop)

      ability = Ability.new(seller)

      expect(ability).not_to be_able_to(:manage, other_shop)
    end
  end

  describe "no user" do
    it "grants nothing" do
      ability = Ability.new(nil)

      expect(ability).not_to be_able_to(:manage, create(:shop))
    end
  end
end
