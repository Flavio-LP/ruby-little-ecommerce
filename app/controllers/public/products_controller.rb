module Public
  class ProductsController < ApplicationController
    def index
      @products = Product.where(active: true).order(:name)
    end

    def show
      @product = Product.where(active: true).find(params[:id])
    end

    def add_to_cart
      product = Product.where(active: true).find(params[:id])
      result = Carts::AddItem.call(cart: current_cart, product: product, quantity: 1)

      respond_to do |format|
        format.turbo_stream do
          if result.success?
            render turbo_stream: turbo_stream.replace("cart_count", partial: "shared/cart_count")
          else
            flash.now[:alert] = result.error
            render turbo_stream: turbo_stream.replace("cart_count", partial: "shared/cart_count")
          end
        end
        format.html do
          redirect_to produtos_path(shop_slug: params[:shop_slug]), notice: result.success? ? "Added to cart." : result.error
        end
      end
    end
  end
end
