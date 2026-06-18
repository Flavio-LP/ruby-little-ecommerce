module Public
  class CartItemsController < ApplicationController
    before_action :set_cart_item

    def update
      quantity = params.dig(:cart_item, :quantity).to_i

      if quantity <= 0
        @cart_item.destroy
      else
        @cart_item.update(quantity: quantity)
      end

      @cart = current_cart
      render_cart_update
    end

    def destroy
      @cart_item.destroy
      @cart = current_cart
      render_cart_update
    end

    private

    def set_cart_item
      @cart_item = current_cart.cart_items.find(params[:id])
    end

    def render_cart_update
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cart_path(shop_slug: params[:shop_slug]) }
      end
    end
  end
end
