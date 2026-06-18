module Admin
  class OrdersController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize! :read, Order
      @orders = Order.all.order(created_at: :desc)
    end

    def show
      @order = Order.find(params[:id])
      authorize! :read, @order
    end
  end
end
