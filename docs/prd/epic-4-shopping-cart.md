# Epic 4 Shopping Cart

**Goal:** Permitir que clientes montem um carrinho de compras por loja, com interações fluidas via Turbo, preparando o terreno para o checkout.

## Story 4.1 Cart and CartItem Models

As a developer,
I want `Cart` and `CartItem` models scoped per shop,
so that a customer's cart contents are isolated to a single store.

### Acceptance Criteria

1: `Cart` has `shop_id`, `user_id` (nullable, for guest carts identified by session token).
2: `CartItem` has `cart_id`, `product_id`, `quantity`, `unit_price_cents` (snapshot taken at add-time, not recalculated from `Product#price_cents` later).
3: A model spec verifies that adding the same product twice increments `quantity` rather than creating a duplicate row.

## Story 4.2 Add to Cart via Turbo

As a customer,
I want to add a product to my cart from the storefront without a full page reload,
so that browsing and shopping feels fast and modern.

### Acceptance Criteria

1: A `Cart::AddItem` Interactor handles validation (product belongs to the shop, is active) and persistence.
2: The "Add to Cart" action uses a Turbo Frame/Stream to update the cart icon/count without a full page navigation.
3: A feature spec (Capybara, JS driver) verifies adding an item updates the visible cart count without a page reload assertion failing.
4: Adding a product from a different shop than the one in context is rejected (validated by a request/feature spec).

## Story 4.3 View and Update Cart

As a customer,
I want to view my cart and update quantities or remove items,
so that I can adjust my order before checking out.

### Acceptance Criteria

1: `/:shop_slug/cart` shows current items, quantities, line subtotals, and a grand total.
2: Quantity can be updated inline (Turbo Stream update) and removing an item updates the total without a full reload.
3: An empty cart shows a clear empty-state message instead of an empty table.
4: A feature spec covers update-quantity and remove-item flows.
