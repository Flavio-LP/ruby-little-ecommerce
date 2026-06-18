class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include CanCan::ControllerAdditions

  set_current_tenant_through_filter
  before_action :set_current_shop, if: -> { params[:shop_slug].present? }

  rescue_from CanCan::AccessDenied do |exception|
    redirect_back fallback_location: "/", alert: exception.message
  end

  private

  def set_current_shop
    shop = Shop.find_by!(slug: params[:shop_slug])
    set_current_tenant(shop)
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError, "Shop not found for slug '#{params[:shop_slug]}'"
  end
end
