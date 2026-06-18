# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.seller?
      can :manage, Shop, id: user.shop_id
      can :manage, Product, shop_id: user.shop_id
      can %i[read], Order, shop_id: user.shop_id
    elsif user.customer?
      # Cart/Order rules scoped to the customer's own user_id are added
      # in Epic 4/5, once those models exist.
    end
  end
end
