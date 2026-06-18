# Epic 3 Product Catalog Management

**Goal:** Permitir que vendedores administrem seu catálogo de produtos dentro do isolamento de tenant já estabelecido, e que clientes visualizem uma vitrine pública por loja.

## Story 3.1 Product Model with Tenant Scoping

As a developer,
I want a `Product` model that uses `acts_as_tenant(:shop)`,
so that every query automatically scopes to the current shop without manual filtering.

### Acceptance Criteria

1: `Product` has `shop_id`, `name`, `description`, `price_cents` (integer), `sku`, `active` (boolean, default true).
2: `Product` declares `acts_as_tenant(:shop)`.
3: A model spec verifies that, with `ActsAsTenant.current_tenant` set to Shop A, `Product.all` does not return Shop B's products even when both exist in the database.

## Story 3.2 Seller Product CRUD

As a seller,
I want to create, edit, list, and deactivate products in my shop's admin area,
so that I can manage what I'm selling.

### Acceptance Criteria

1: `/:shop_slug/admin/products` supports index, new/create, edit/update, and a deactivate action (soft delete via `active: false`, not a hard destroy).
2: All actions are authorized via `Ability` (`can :manage, Product, shop_id: user.shop_id`).
3: Attempting to edit another shop's product (by guessing an ID) returns 404/403, verified by a request spec.
4: A feature spec covers creating a product through the form and seeing it appear in the index.

## Story 3.3 Public Storefront Product Listing

As a customer,
I want to browse a shop's public product listing,
so that I can find items to buy before any cart functionality exists.

### Acceptance Criteria

1: `/:shop_slug/produtos` is a public (no auth required) route listing only `active: true` products for that shop.
2: Inactive products and products from other shops never appear, verified by a feature spec with multiple shops/products fixtures.
3: Each product links to a detail page (`/:shop_slug/produtos/:id`) showing full description and price.
