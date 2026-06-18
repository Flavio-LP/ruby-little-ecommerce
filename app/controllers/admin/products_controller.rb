module Admin
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: %i[edit update deactivate]

    def index
      authorize! :manage, Product
      @products = Product.all.order(created_at: :desc)
    end

    def new
      authorize! :manage, Product
      @product = Product.new
    end

    def create
      authorize! :manage, Product
      @product = Product.new(product_params)
      @product.shop = ActsAsTenant.current_tenant

      if @product.save
        redirect_to admin_products_path(shop_slug: params[:shop_slug]), notice: "Product created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize! :manage, @product
    end

    def update
      authorize! :manage, @product

      if @product.update(product_params)
        redirect_to admin_products_path(shop_slug: params[:shop_slug]), notice: "Product updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def deactivate
      authorize! :manage, @product
      @product.update!(active: false)
      redirect_to admin_products_path(shop_slug: params[:shop_slug]), notice: "Product deactivated."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :price_cents, :sku, :active)
    end
  end
end
