module Public
  class ProductsController < ApplicationController
    def index
      @products = Product.where(active: true).order(:name)
    end

    def show
      @product = Product.where(active: true).find(params[:id])
    end
  end
end
