# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.seller?
      can :manage, Shop, id: user.shop_id
      can :manage, Product, shop_id: user.shop_id
      # Order rules following the same shop_id == user.shop_id pattern
      # are added in Epic 5, once that model exists.
    elsif user.customer?
      # Cart/Order rules scoped to the customer's own user_id are added
      # in Epic 4/5, once those models exist.
    end
  end
end
