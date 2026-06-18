module Public
  class CheckoutController < ApplicationController
    def create
      result = Checkout::CreateOrder.call(cart: current_cart, user: current_user)

      if result.success?
        redirect_to confirmation_checkout_path(shop_slug: params[:shop_slug], order_id: result.order.id)
      else
        redirect_to cart_path(shop_slug: params[:shop_slug]), alert: result.error
      end
    end

    def confirmation
      @order = Order.find(params[:order_id])
    end
  end
end
