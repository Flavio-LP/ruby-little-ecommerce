# Database Schema

```sql
CREATE TABLE shops (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  slug VARCHAR NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  UNIQUE (slug)
);

CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR NOT NULL DEFAULT '',
  encrypted_password VARCHAR NOT NULL DEFAULT '',
  role INTEGER NOT NULL DEFAULT 1, -- 0=seller, 1=customer
  shop_id BIGINT REFERENCES shops(id),
  -- demais campos padrão do Devise (reset_password_token, etc.)
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  UNIQUE (email)
);
CREATE INDEX index_users_on_shop_id ON users (shop_id);

CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  shop_id BIGINT NOT NULL REFERENCES shops(id),
  name VARCHAR NOT NULL,
  description TEXT,
  price_cents INTEGER NOT NULL,
  sku VARCHAR,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
CREATE INDEX index_products_on_shop_id ON products (shop_id);

CREATE TABLE carts (
  id BIGSERIAL PRIMARY KEY,
  shop_id BIGINT NOT NULL REFERENCES shops(id),
  user_id BIGINT REFERENCES users(id),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
CREATE INDEX index_carts_on_shop_id ON carts (shop_id);

CREATE TABLE cart_items (
  id BIGSERIAL PRIMARY KEY,
  cart_id BIGINT NOT NULL REFERENCES carts(id),
  product_id BIGINT NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price_cents INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  UNIQUE (cart_id, product_id)
);

CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  shop_id BIGINT NOT NULL REFERENCES shops(id),
  user_id BIGINT REFERENCES users(id),
  status INTEGER NOT NULL DEFAULT 0, -- 0=pending,1=paid,2=fulfilled,3=cancelled
  total_cents INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
CREATE INDEX index_orders_on_shop_id ON orders (shop_id);

CREATE TABLE line_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id),
  product_id BIGINT NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_price_cents INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```
