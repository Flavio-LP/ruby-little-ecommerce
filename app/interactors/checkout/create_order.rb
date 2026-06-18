module Checkout
  # Converts a Cart into an immutable Order + LineItems, clears the cart,
  # and enqueues a confirmation notification.
  # context in: cart, user (optional, for guest checkout)
  # context out: order
  class CreateOrder
    include Interactor

    def call
      cart = context.cart

      if cart.cart_items.empty?
        context.fail!(error: "Your cart is empty")
        return
      end

      ActiveRecord::Base.transaction do
        order = Order.create!(
          shop: cart.shop,
          user: context.user,
          status: :pending,
          total_cents: cart.total_cents
        )

        cart.cart_items.each do |cart_item|
          order.line_items.create!(
            product: cart_item.product,
            quantity: cart_item.quantity,
            unit_price_cents: cart_item.unit_price_cents
          )
        end

        cart.cart_items.destroy_all

        context.order = order
      end

      OrderConfirmationJob.perform_later(context.order.id)
    end
  end
end
