module Shops
  # Creates a seller User + their own Shop in a single transaction.
  # context in: email, password, password_confirmation, shop_name
  # context out: user, shop
  class Register
    include Interactor

    def call
      ActiveRecord::Base.transaction do
        user = User.new(
          email: context.email,
          password: context.password,
          password_confirmation: context.password_confirmation,
          role: :seller
        )

        unless user.save
          context.fail!(error: user.errors.full_messages.to_sentence)
        end

        shop = Shop.new(name: context.shop_name, slug: unique_slug_for(context.shop_name))

        unless shop.save
          context.fail!(error: shop.errors.full_messages.to_sentence)
        end

        user.update!(shop: shop)

        context.user = user
        context.shop = shop
      end
    end

    private

    def unique_slug_for(name)
      base_slug = name.to_s.parameterize
      slug = base_slug
      suffix = 1

      while Shop.exists?(slug: slug)
        suffix += 1
        slug = "#{base_slug}-#{suffix}"
      end

      slug
    end
  end
end
