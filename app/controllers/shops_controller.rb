# Root page: lists every shop on the platform so customers can browse
# into a specific storefront. Not tenant-scoped — this is the one route
# that intentionally has no :shop_slug.
class ShopsController < ApplicationController
  def index
    @shops = Shop.order(:name)
  end
end
