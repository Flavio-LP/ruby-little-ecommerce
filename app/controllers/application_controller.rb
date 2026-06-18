class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include CanCan::ControllerAdditions

  set_current_tenant_through_filter
  before_action :set_current_shop, if: -> { params[:shop_slug].present? }

  helper_method :current_cart

  rescue_from CanCan::AccessDenied do |exception|
    redirect_back fallback_location: "/", alert: exception.message
  end

  # Sellers land on their own shop's dashboard after logging in (not just
  # after registering); everyone else falls back to Devise's default
  # (stored location, or root — the shop directory).
  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.seller? && resource.shop.present?
      admin_dashboard_path(shop_slug: resource.shop.slug)
    else
      super
    end
  end

  # Send users back to the login screen after logging out, instead of
  # Devise's default (root — the shop directory).
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  private

  def set_current_shop
    shop = Shop.find_by!(slug: params[:shop_slug])
    set_current_tenant(shop)
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError, "Shop not found for slug '#{params[:shop_slug]}'"
  end

  # Resolves (and lazily creates) the cart for the current shop, identifying
  # the customer either by their signed-in User or by a long-lived signed
  # cookie token for guest checkout.
  def current_cart
    return @current_cart if defined?(@current_cart)

    shop = ActsAsTenant.current_tenant
    return @current_cart = nil unless shop

    @current_cart =
      if current_user
        Cart.find_or_create_by!(shop: shop, user: current_user)
      else
        Cart.find_or_create_by!(shop: shop, guest_token: guest_cart_token)
      end
  end

  def guest_cart_token
    cookies.permanent.signed[:guest_cart_token] ||= SecureRandom.uuid
  end
end
