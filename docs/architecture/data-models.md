# Data Models

## Shop

**Purpose:** Representa o tenant — uma loja de um vendedor.

**Key Attributes:**
- `name`: string — nome de exibição da loja
- `slug`: string (unique, indexed) — usado no roteamento `/:shop_slug/...`

**Relationships:**
- `has_one :owner` (User com `role: seller`)
- `has_many :products`, `has_many :orders`, `has_many :carts` (todos `acts_as_tenant(:shop)`)

## User (Devise)

**Purpose:** Identidade única para vendedores e clientes.

**Key Attributes:**
- `email`, `encrypted_password` (Devise padrão)
- `role`: integer enum (`seller`, `customer`)
- `shop_id`: bigint, nullable (FK — presente apenas para `role: seller`)

**Relationships:**
- `belongs_to :shop, optional: true` (apenas sellers)
- `has_many :orders` (como comprador, quando `role: customer`)

## Product

**Purpose:** Item de catálogo pertencente a uma loja.

**Key Attributes:**
- `shop_id`: bigint (FK, tenant scope)
- `name`, `description`: string/text
- `price_cents`: integer
- `sku`: string
- `active`: boolean (default true)

**Relationships:**
- `belongs_to :shop` — `acts_as_tenant(:shop)`
- `has_many :cart_items`, `has_many :line_items`

## Cart / CartItem

**Purpose:** Carrinho de compras temporário, por loja, por cliente (ou guest).

**Key Attributes (Cart):** `shop_id`, `user_id` (nullable)
**Key Attributes (CartItem):** `cart_id`, `product_id`, `quantity`, `unit_price_cents` (snapshot)

**Relationships:**
- `Cart belongs_to :shop` (`acts_as_tenant(:shop)`), `has_many :cart_items`
- `CartItem belongs_to :cart`, `belongs_to :product`

## Order / LineItem

**Purpose:** Pedido finalizado e imutável, por loja.

**Key Attributes (Order):** `shop_id`, `user_id` (comprador), `status` enum (`pending`/`paid`/`fulfilled`/`cancelled`), `total_cents`
**Key Attributes (LineItem):** `order_id`, `product_id`, `quantity`, `unit_price_cents` (snapshot, nunca recalculado)

**Relationships:**
- `Order belongs_to :shop` (`acts_as_tenant(:shop)`), `belongs_to :user`, `has_many :line_items`
- `LineItem belongs_to :order`, `belongs_to :product`

## Ability (CanCanCan — não é tabela)

**Purpose:** Classe única (`app/models/ability.rb`) definindo regras de autorização por `role`, cruzadas com `shop_id` para reforçar a fronteira de tenant também na camada de autorização.
