module Carts
  # Adds a product to a cart, incrementing quantity if it's already present.
  # Named Carts::AddItem (plural namespace), not Cart::AddItem, to avoid
  # colliding with the top-level Cart ActiveRecord model — same convention
  # as Shops::Register vs the Shop model.
  #
  # context in: cart, product, quantity (default 1)
  # context out: cart_item
  class AddItem
    include Interactor

    def call
      cart = context.cart
      product = context.product
      quantity = context.quantity || 1

      unless product.active? && product.shop_id == cart.shop_id
        context.fail!(error: "Product is not available in this shop")
        return
      end

      cart_item = cart.cart_items.find_or_initialize_by(product: product)
      base_quantity = cart_item.new_record? ? 0 : cart_item.quantity
      cart_item.unit_price_cents ||= product.price_cents
      cart_item.quantity = base_quantity + quantity

      unless cart_item.save
        context.fail!(error: cart_item.errors.full_messages.to_sentence)
        return
      end

      context.cart_item = cart_item
    end
  end
end
