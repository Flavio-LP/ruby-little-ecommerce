# Epic 5 Checkout & Orders

**Goal:** Permitir que o cliente finalize a compra criando um pedido imutável, e que o vendedor visualize os pedidos recebidos em sua loja — fechando o ciclo de valor do MVP.

## Story 5.1 Order and LineItem Models

As a developer,
I want `Order` and `LineItem` models that snapshot price/quantity at checkout time,
so that historical orders remain accurate even if product prices change later.

### Acceptance Criteria

1: `Order` has `shop_id`, `user_id` (buyer, nullable for guest checkout if supported), `status` (enum: `pending`, `paid`, `fulfilled`, `cancelled`), `total_cents`.
2: `LineItem` has `order_id`, `product_id`, `quantity`, `unit_price_cents` (copied from the `CartItem` at checkout time).
3: A model spec verifies that changing a `Product`'s `price_cents` after an order is placed does not alter the `LineItem`'s stored `unit_price_cents`.

## Story 5.2 Checkout Flow Creates an Order

As a customer,
I want to convert my cart into a finalized order,
so that my purchase is recorded and the seller is notified.

### Acceptance Criteria

1: A `Checkout::CreateOrder` Interactor: validates the cart is non-empty, creates `Order` + `LineItem`s from current `CartItem`s within a transaction, clears the cart on success, sets `status: pending`.
2: On success, the customer is redirected to an order confirmation page showing the order summary.
3: A `OrderConfirmationJob` (Sidekiq) is enqueued to send a confirmation notification (email delivery itself can be a stub/log-based `ActionMailer` preview in MVP).
4: A feature spec covers the full cart-to-confirmation flow, including verifying the job was enqueued (`ActiveJob::TestHelper`).
5: Checkout with an empty cart is rejected with a clear error message, not a 500.

## Story 5.3 Seller Order Visibility

As a seller,
I want to see orders placed in my shop,
so that I know what to fulfill.

### Acceptance Criteria

1: `/:shop_slug/admin/orders` lists orders for the current shop only (tenant-scoped via `acts_as_tenant`), ordered most-recent-first.
2: Each order row links to a detail view showing line items, quantities, and total.
3: A request spec verifies a seller cannot view another shop's orders by guessing an order ID (403/404).
