# Schema Design (Data Engineering Detail)

> Complementa `docs/architecture/data-models.md` e `docs/architecture/database-schema.md` com o nível de detalhe de migration Rails necessário para `@dev` implementar a Epic 1 (Story 1.3) em diante. Produzido por `@data-engineer` a partir de `docs/architecture.md`.

## Ordem de migrations

1. `CreateShops`
2. Devise `CreateUsers` (gerado por `devise:install` + `devise User`) + migration de adição da coluna `role` e `shop_id`
3. `CreateProducts`
4. `CreateCarts`, `CreateCartItems`
5. `CreateOrders`, `CreateLineItems`

Esta ordem respeita FKs: `users.shop_id` depende de `shops`; `products`, `carts`, `orders` dependem de `shops`; `cart_items`/`line_items` dependem de seus pais e de `products`.

## Shop

```ruby
create_table :shops do |t|
  t.string :name, null: false
  t.string :slug, null: false
  t.timestamps
end
add_index :shops, :slug, unique: true
```

`Shop` model: `validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }`.

## User (Devise + tenant/role extensions)

Gerado por `rails generate devise User`, depois uma migration adicional:

```ruby
add_column :users, :role, :integer, null: false, default: 1 # 0=seller, 1=customer
add_column :users, :shop_id, :bigint
add_index :users, :shop_id
add_foreign_key :users, :shops
```

`User` model: `enum role: { seller: 0, customer: 1 }`, `belongs_to :shop, optional: true`. Validação: um `User` com `role: seller` deve ter `shop_id` presente após `Shops::Register` rodar (mas a FK em si é nullable para permitir o passo intermediário da transação de registro).

## Product

```ruby
create_table :products do |t|
  t.references :shop, null: false, foreign_key: true
  t.string :name, null: false
  t.text :description
  t.integer :price_cents, null: false
  t.string :sku
  t.boolean :active, null: false, default: true
  t.timestamps
end
```

`Product` model: `acts_as_tenant(:shop)`, `validates :name, :price_cents, presence: true`, `validates :price_cents, numericality: { greater_than: 0 }`.

## Cart / CartItem

```ruby
create_table :carts do |t|
  t.references :shop, null: false, foreign_key: true
  t.references :user, foreign_key: true # nullable -> guest cart
  t.timestamps
end

create_table :cart_items do |t|
  t.references :cart, null: false, foreign_key: true
  t.references :product, null: false, foreign_key: true
  t.integer :quantity, null: false, default: 1
  t.integer :unit_price_cents, null: false
  t.timestamps
end
add_index :cart_items, [:cart_id, :product_id], unique: true
```

`Cart` model: `acts_as_tenant(:shop)`, `has_many :cart_items, dependent: :destroy`.
`CartItem` model: `belongs_to :cart`, `belongs_to :product`; `unit_price_cents` é setado uma única vez a partir de `product.price_cents` no momento da criação (no Interactor `Cart::AddItem`, nunca recalculado depois).

## Order / LineItem

```ruby
create_table :orders do |t|
  t.references :shop, null: false, foreign_key: true
  t.references :user, foreign_key: true
  t.integer :status, null: false, default: 0 # 0=pending,1=paid,2=fulfilled,3=cancelled
  t.integer :total_cents, null: false
  t.timestamps
end

create_table :line_items do |t|
  t.references :order, null: false, foreign_key: true
  t.references :product, null: false, foreign_key: true
  t.integer :quantity, null: false
  t.integer :unit_price_cents, null: false
  t.timestamps
end
```

`Order` model: `acts_as_tenant(:shop)`, `enum status: { pending: 0, paid: 1, fulfilled: 2, cancelled: 3 }`, `has_many :line_items, dependent: :destroy`.
`LineItem` model: `belongs_to :order`, `belongs_to :product`; criado apenas dentro de `Checkout::CreateOrder`, copiando `unit_price_cents` do `CartItem` correspondente — nunca de `product.price_cents` diretamente nesse passo (o `CartItem` já é o snapshot de referência).

## acts_as_tenant configuração global

`config/initializers/acts_as_tenant.rb`:

```ruby
ActsAsTenant.configure do |config|
  config.require_tenant = true # força todo model com acts_as_tenant a exigir tenant setado, evita esquecimento
end
```

`ApplicationController`:

```ruby
set_current_tenant_through_filter
before_action :set_current_shop

private

def set_current_shop
  shop = Shop.find_by!(slug: params[:shop_slug])
  set_current_tenant(shop)
rescue ActiveRecord::RecordNotFound
  raise ActionController::RoutingError, "Shop not found"
end
```

## Seeds (`db/seeds.rb`)

Criar 2 shops de exemplo com produtos, para suportar manualmente os testes de feature/exploração durante o desenvolvimento (não usado pela suíte automatizada, que deve usar factories isoladas).
