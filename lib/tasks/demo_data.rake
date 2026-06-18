namespace :demo do
  desc "Cria 3 lojas, 2 produtos diferentes em cada loja e 2 acessos de cliente"
  task seed: :environment do
    shops = [
      { name: "Loja Aurora", slug: "loja-aurora" },
      { name: "Loja Boreal", slug: "loja-boreal" },
      { name: "Loja Cedro", slug: "loja-cedro" }
    ].map do |attrs|
      shop = Shop.find_or_create_by!(slug: attrs[:slug]) { |s| s.name = attrs[:name] }
      puts "Loja: #{shop.name} (#{shop.slug})"
      shop
    end

    shops.each do |shop|
      admin = User.find_or_create_by!(email: "admin-#{shop.slug}@example.com") do |u|
        u.password = "password123"
        u.password_confirmation = "password123"
        u.role = :seller
        u.shop = shop
      end
      puts "Administrador: #{admin.email} (#{shop.slug})"
    end

    shops.each_with_index do |shop, index|
      ActsAsTenant.with_tenant(shop) do
        [
          { name: "Produto #{index + 1}A", sku: "SKU-#{shop.slug}-A", price_cents: 1_990 },
          { name: "Produto #{index + 1}B", sku: "SKU-#{shop.slug}-B", price_cents: 4_990 }
        ].each do |attrs|
          product = Product.find_or_create_by!(sku: attrs[:sku]) do |p|
            p.name = attrs[:name]
            p.price_cents = attrs[:price_cents]
            p.active = true
          end
          puts "  Produto: #{product.name} (#{product.sku})"
        end
      end
    end

    [
      { email: "cliente1@example.com" },
      { email: "cliente2@example.com" }
    ].each do |attrs|
      customer = User.find_or_create_by!(email: attrs[:email]) do |u|
        u.password = "password123"
        u.password_confirmation = "password123"
        u.role = :customer
      end
      puts "Cliente: #{customer.email}"
    end
  end
end
