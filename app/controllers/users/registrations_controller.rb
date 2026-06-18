module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      shop_name = params.dig(:user, :shop_name)

      if shop_name.present?
        create_seller_with_shop(shop_name)
      else
        super
      end
    end

    private

    def create_seller_with_shop(shop_name)
      result = Shops::Register.call(
        email: params.dig(:user, :email),
        password: params.dig(:user, :password),
        password_confirmation: params.dig(:user, :password_confirmation),
        shop_name: shop_name
      )

      if result.success?
        sign_in(result.user)
        redirect_to admin_dashboard_path(shop_slug: result.shop.slug),
          notice: "Welcome! Your shop \"#{result.shop.name}\" is ready."
      else
        self.resource = User.new(email: params.dig(:user, :email), role: :seller)
        resource.errors.add(:base, result.error)
        render :new, status: :unprocessable_content
      end
    end

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :shop_name)
    end
  end
end
