# Epic 2 Multi-Tenant Seller Onboarding

**Goal:** Estabelecer a fronteira de tenant que todo o restante da aplicação depende: vendedores se cadastram, ganham uma loja própria com slug único, e acessam um painel administrativo restrito àquela loja.

## Story 2.1 Shop Model and Tenant Scoping Infrastructure

As a developer,
I want a `Shop` model and the `acts_as_tenant` configuration wired into `ApplicationController`,
so that every tenant-scoped model created in later epics automatically inherits data isolation.

### Acceptance Criteria

1: `Shop` model exists with `name`, `slug` (unique, indexed, URL-safe format validated).
2: `acts_as_tenant` is configured with `Shop` as the tenant class.
3: `ApplicationController` resolves the current tenant from `params[:shop_slug]` via `set_current_tenant_through_filter`, raising a 404 (not a 500) when the slug doesn't match any `Shop`.
4: A request spec verifies that visiting a route with an invalid `shop_slug` returns 404.

## Story 2.2 Seller Registration Creates a Shop

As a prospective seller,
I want to register an account and have a shop automatically created for me,
so that I can start managing my own store immediately after signing up.

### Acceptance Criteria

1: A `Shops::Register` Interactor encapsulates: create `User` with `role: seller`, create associated `Shop` with a slug derived from the shop name (uniqueness enforced, suffixing if needed), wrapped in a database transaction.
2: The seller registration form collects shop name in addition to standard Devise fields.
3: On success, the seller is signed in and redirected to their shop's admin dashboard (`/:shop_slug/admin`).
4: A feature spec (Capybara) covers the full registration-to-dashboard-redirect flow.
5: A failure in shop creation rolls back the user creation (no orphaned `User` without a `Shop`).

## Story 2.3 Seller Admin Dashboard Shell

As a seller,
I want a dashboard page scoped to my own shop,
so that I have a starting point to manage my store before product/order features exist.

### Acceptance Criteria

1: `/:shop_slug/admin` route exists, requiring authentication and `role: seller`, and requiring `current_user.shop_id == current Shop.id` (a seller cannot view another shop's admin area even if authenticated).
2: Attempting to access another shop's admin area as an authenticated seller returns 403 (via CanCanCan `Ability`/`authorize!`).
3: The dashboard renders placeholder sections for "Products" and "Orders" (populated in later epics).
4: A request spec verifies the cross-tenant access denial (403) explicitly.

## Story 2.4 Ability Rules for Seller/Shop Ownership

As a developer,
I want `Ability` rules that scope seller permissions to their own `Shop`,
so that authorization and tenant isolation work together consistently across the app.

### Acceptance Criteria

1: `Ability` grants sellers `:manage` on resources where `shop_id == user.shop_id` (pattern to be reused by `Product`/`Order` in later epics).
2: `Ability` denies sellers any action on resources belonging to a different `shop_id`.
3: A model/unit spec for `Ability` verifies both the grant and the denial case using a stub/double resource.
