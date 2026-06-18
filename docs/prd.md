# Web E-Commerce Multi-Tenant Product Requirements Document (PRD)

## Goals and Background Context

### Goals

- Permitir que múltiplos vendedores (tenants) operem lojas independentes na mesma plataforma, sem visibilidade cruzada de dados.
- Oferecer um catálogo de produtos simples que cada vendedor administra de forma isolada.
- Permitir que clientes naveguem por uma loja específica, montem um carrinho e finalizem a compra (checkout).
- Garantir que toda a stack (Docker, Rails, Devise/CanCanCan, RSpec/Capybara, Sidekiq/Redis, PostgreSQL) esteja operacional desde o primeiro epic, com gate de segurança (Brakeman) no pipeline de CI.
- Entregar o MVP em incrementos verticais e testáveis, sem deixar infraestrutura/segurança como tarefas de última hora.

### Background Context

Este projeto nasce como uma plataforma de e-commerce inspirada no modelo Shopify: em vez de um único catálogo, a aplicação hospeda diversas lojas (tenants) simultaneamente, cada uma pertencente a um vendedor que gerencia seus próprios produtos e recebe seus próprios pedidos. Não existe código de produto ainda — apenas o scaffold padrão do Rails 8 — então o MVP precisa estabelecer a fundação (Docker, autenticação, isolamento multi-tenant) antes de qualquer feature de catálogo/carrinho/checkout.

A escolha de isolamento por linha (`acts_as_tenant` com `shop_id`) em vez de isolamento por schema (Apartment) foi feita para manter a complexidade operacional baixa (sem N migrations por schema, sem necessidade de trocar contexto de schema em jobs do Sidekiq), adequada ao escopo "e-commerce simples" solicitado. O roteamento por path (`/:shop_slug/...`) foi escolhido sobre subdomínio para evitar configuração de DNS/hosts em ambiente Docker local.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2026-06-17 | 0.1 | Versão inicial do PRD, criada a partir da descrição do usuário e decisões de arquitetura (multi-tenancy, roteamento) aprovadas em plano. | @pm (Morgan) |

## Requirements

### Functional

1. FR1: O sistema deve permitir que um vendedor se cadastre e, nesse processo, criar automaticamente sua própria loja (`Shop`) com um slug único usado no roteamento (`/:shop_slug/...`).
2. FR2: O sistema deve permitir que um vendedor autentique-se (login/logout) via Devise e acesse um painel administrativo restrito à sua própria loja.
3. FR3: O sistema deve permitir que um vendedor crie, edite, liste e desative produtos (nome, descrição, preço, SKU) dentro da sua própria loja.
4. FR4: O sistema deve impedir, em nível de dados, que um vendedor visualize ou modifique produtos/pedidos de outra loja (isolamento de tenant).
5. FR5: O sistema deve expor uma página pública de vitrine por loja (`/:shop_slug/produtos`) listando os produtos ativos daquela loja.
6. FR6: O sistema deve permitir que um cliente (autenticado ou visitante) adicione produtos a um carrinho de compras vinculado a uma loja específica.
7. FR7: O sistema deve permitir que o cliente atualize a quantidade ou remova itens do carrinho antes do checkout.
8. FR8: O sistema deve permitir que o cliente finalize o checkout, criando um pedido (`Order`) imutável com os itens, quantidades e preços vigentes no momento da compra.
9. FR9: O sistema deve permitir que o vendedor visualize, em seu painel, os pedidos recebidos em sua loja.
10. FR10: O sistema deve expor uma rota de health-check que retorna 200 quando a aplicação e suas dependências (banco, Redis) estão operacionais.
11. FR11: O sistema deve registrar/processar tarefas assíncronas (ex.: envio de e-mail de confirmação de pedido) via Sidekiq, sem bloquear a requisição HTTP do checkout.

### Non Functional

1. NFR1: Toda a persistência de dados deve ocorrer exclusivamente em PostgreSQL — nenhum dado de negócio deve viver apenas em cache/Redis.
2. NFR2: O ambiente de desenvolvimento completo (app, banco, Redis, worker) deve subir via `docker compose up` sem passos manuais adicionais.
3. NFR3: Toda lógica de negócio não-trivial (ex.: criação de pedido, registro de loja) deve ser implementada como objetos `Interactor`, mantendo controllers magros.
4. NFR4: Toda autorização de ações (quem pode fazer o quê) deve ser centralizada em classes CanCanCan `Ability`, nunca em condicionais espalhadas em controllers/views.
5. NFR5: Todo isolamento de dados entre tenants deve ser garantido estruturalmente via `acts_as_tenant` (escopo automático de query), não por filtros manuais espalhados pelo código.
6. NFR6: A suíte de testes (RSpec + Capybara) deve cobrir os fluxos críticos (cadastro de vendedor, CRUD de produto, carrinho, checkout) com testes de feature, além de testes unitários para Interactors e models.
7. NFR7: O pipeline de CI deve rodar `bundle exec rspec` e `bundle exec brakeman` em todo push/PR, bloqueando merge quando o Brakeman reportar findings de severidade alta/crítica.
8. NFR8: A interface deve ser server-rendered (HTML+ERB) com Bootstrap para estilo e Turbo para navegação sem reload completo; JavaScript customizado deve ser usado apenas onde Turbo/Stimulus não for suficiente.

## User Interface Design Goals

### Overall UX Vision

Interface simples e funcional, sem necessidade de SPA: páginas renderizadas no servidor com Bootstrap para grid/componentes e Turbo Drive/Frames para tornar ações como adicionar ao carrinho ou atualizar quantidade fluidas, sem reload completo da página.

### Key Interaction Paradigms

- Navegação tradicional por links/formulários Rails, com Turbo interceptando para evitar reloads.
- Ações de carrinho (adicionar/remover/atualizar) via Turbo Frames/Streams, atualizando apenas a seção relevante da página.
- Painel do vendedor como uma área autenticada distinta da vitrine pública, ambas sob o mesmo `shop_slug`.

### Core Screens and Views

- Tela de cadastro/login (vendedor e cliente)
- Dashboard do vendedor (lista de produtos, lista de pedidos)
- Formulário de produto (criar/editar)
- Vitrine pública da loja (lista de produtos ativos)
- Página de detalhe do produto
- Carrinho de compras
- Checkout / confirmação de pedido
- Rota de health-check (sem UI, retorno JSON/texto simples)

### Accessibility: None

MVP não exige conformidade WCAG formal, mas deve seguir boas práticas básicas de HTML semântico (labels em formulários, contraste mínimo do Bootstrap padrão).

### Branding

Nenhuma identidade visual definida ainda — usar o tema padrão do Bootstrap sem customização nesta fase.

### Target Device and Platforms: Web Responsive

Web responsivo (desktop e mobile via grid do Bootstrap), sem app nativo nesta fase.

## Technical Assumptions

### Repository Structure: Monorepo

Aplicação Rails única (monólito), sem necessidade de múltiplos repositórios para o MVP.

### Service Architecture

**Monolito Rails modular.** Um único processo web (Puma) servindo HTML, mais um processo worker (Sidekiq) consumindo a mesma base de código para jobs assíncronos. Multi-tenancy é tratada dentro do monólito via `acts_as_tenant` (escopo de dados), não via serviços separados por tenant. Esta decisão evita a complexidade operacional de microsserviços/schema-per-tenant, adequada ao escopo "e-commerce simples" do MVP.

### Testing Requirements

**Full Testing Pyramid (adaptado):** testes unitários (models, Interactors, Ability classes) + testes de feature end-to-end com RSpec + Capybara para os fluxos críticos (cadastro de vendedor, CRUD de produto, carrinho, checkout). Minitest padrão do Rails será removido em favor de RSpec na Epic 1.

### Additional Technical Assumptions and Requests

- **Multi-tenancy:** gem `acts_as_tenant`, com `shop_id` em todo modelo tenant-scoped (`Product`, `Cart`, `Order`). Resolução do tenant atual via `before_action` no `ApplicationController`, lendo `params[:shop_slug]`.
- **Roteamento de tenant:** por path (`/:shop_slug/...`), não por subdomínio — decisão tomada para simplificar o ambiente Docker de desenvolvimento (sem necessidade de DNS wildcard/`/etc/hosts`).
- **Autenticação:** Devise, modelo único `User` com coluna `role` (enum `seller`/`customer`) em vez de múltiplos scopes Devise.
- **Autorização:** CanCanCan, com classe `Ability` ramificando regras por `role` e validando pertencimento ao `shop_id` correto.
- **Padrão de lógica de negócio:** gem `interactor` para operações como `Shops::Register`, `Cart::AddItem`, `Checkout::CreateOrder`.
- **Background jobs:** Sidekiq + Redis, ex.: envio de e-mail de confirmação de pedido após checkout.
- **Persistência:** PostgreSQL como única fonte de dados; Redis usado apenas como broker do Sidekiq (e cache, se necessário), nunca como armazenamento primário de dados de negócio.
- **Frontend:** ERB + Bootstrap (via gem `bootstrap` ou CDN, a decidir pelo @architect) + Turbo (`turbo-rails`, já presente no Gemfile) + Stimulus para os poucos casos que exigirem JS customizado.
- **Containerização:** Docker Compose para desenvolvimento (serviços: `web`, `db` Postgres, `redis`, `worker` Sidekiq), distinto do `Dockerfile` de produção já existente no repositório (que usa Kamal/Thruster).
- **CI/CD:** pipeline com `bundle exec rspec` e `bundle exec brakeman`, bloqueando merge em findings de severidade alta/crítica do Brakeman.
- **Preço imutável no checkout:** `LineItem`/`CartItem` devem armazenar o preço unitário no momento da ação (snapshot), nunca recalcular a partir do preço atual do `Product`.

## Epic List

- **Epic 1: Foundation & Infrastructure** — Estabelecer o ambiente Docker Compose, a stack de gems (Devise, CanCanCan, Interactor, Sidekiq, RSpec/Capybara), e uma rota de health-check funcional, com CI básico de lint/test já operante desde o início.
- **Epic 2: Multi-Tenant Seller Onboarding** — Permitir que vendedores se cadastrem e tenham sua própria loja isolada (`Shop` + `shop_id`), com painel administrativo básico.
- **Epic 3: Product Catalog Management** — Permitir que vendedores gerenciem produtos dentro de sua loja e que clientes vejam a vitrine pública.
- **Epic 4: Shopping Cart** — Permitir que clientes montem um carrinho de compras por loja, com atualizações via Turbo.
- **Epic 5: Checkout & Orders** — Permitir que clientes finalizem a compra criando um pedido imutável, e que vendedores vejam os pedidos recebidos.
- **Epic 6: CI/CD & Security Gate** — Endurecer o pipeline de CI com o gate de segurança do Brakeman bloqueando merges com findings críticos, agora que existe código de aplicação real para escanear.

## Epic 1 Foundation & Infrastructure

**Goal:** Estabelecer toda a base técnica do projeto — ambiente containerizado, autenticação, autorização, suíte de testes e pipeline de CI — entregando como funcionalidade inicial uma rota de health-check verificável, para que todos os epics seguintes partam de uma fundação estável e testável.

### Story 1.1 Docker Compose Development Environment

As a developer,
I want a `docker-compose.yml` that boots the Rails app, PostgreSQL, and Redis with a single command,
so that anyone can start a working local environment without manual setup.

#### Acceptance Criteria

1: `docker compose up` builds and starts `web`, `db` (Postgres), and `redis` services successfully.
2: A development-specific `Dockerfile.dev` (or equivalent multi-stage target) is used for the `web` service, distinct from the existing production `Dockerfile`.
3: `config/database.yml` is configured to read connection settings from environment variables provided by `docker-compose.yml`.
4: Database data persists across container restarts via a named volume.
5: A `README` section (or `docs/` note) documents how to start the environment and run common commands (`bundle exec rspec`, `rails console`) inside the container.

### Story 1.2 Core Gem Stack Installation

As a developer,
I want the Gemfile updated with `interactor`, `devise`, `cancancan`, `acts_as_tenant`, `sidekiq`, `redis`, `bootstrap`, `rspec-rails`, and `capybara`,
so that the application has the foundation libraries available for every subsequent epic.

#### Acceptance Criteria

1: `Gemfile` includes `interactor`, `devise`, `cancancan`, `acts_as_tenant`, `sidekiq`, `redis`, `bootstrap` (or equivalent asset integration) in the main group, and `rspec-rails`, `capybara` in the `:development, :test` group.
2: `bundle install` completes successfully inside the Docker `web` service.
3: Default Rails Minitest scaffolding (`test/` directory, `Rails.application.config.generators.test_framework`) is removed/replaced in favor of RSpec.
4: `rails generate rspec:install` has been run, producing `spec/spec_helper.rb` and `spec/rails_helper.rb` configured with Capybara feature spec support.

### Story 1.3 Devise Authentication Setup

As a developer,
I want Devise installed with a single `User` model that includes a `role` enum (`seller`/`customer`),
so that both sellers and customers can authenticate through the same mechanism while remaining distinguishable for authorization.

#### Acceptance Criteria

1: `rails generate devise:install` and `rails generate devise User` have been run, producing migrations for the standard Devise fields.
2: `User` model has a `role` column (integer enum: `seller`, `customer`) with a non-null default and a database-level check/constraint or Rails validation enforcing one of the two values.
3: Devise views (registration, sessions) are generated and themed minimally with Bootstrap so they are usable, not just functional defaults.
4: A model spec verifies that a `User` cannot be saved without a valid `role`.

### Story 1.4 CanCanCan Authorization Skeleton

As a developer,
I want CanCanCan installed with an `Ability` class that branches on `User#role`,
so that authorization logic has a single, centralized location from the start of the project.

#### Acceptance Criteria

1: `rails generate cancan:ability` has been run, producing `app/models/ability.rb`.
2: `Ability` defines distinct rule blocks for `role == "seller"` and `role == "customer"` (even if the rule sets are still empty/minimal placeholders pending Epic 2-5 models).
3: `ApplicationController` includes `CanCan::ControllerAdditions` and rescues `CanCan::AccessDenied` with a redirect + flash message.
4: A request spec verifies that an unauthorized action raises/handles `CanCan::AccessDenied` as expected.

### Story 1.5 Sidekiq and Redis Background Job Wiring

As a developer,
I want Sidekiq configured as the Active Job adapter, connected to the Redis service from docker-compose,
so that asynchronous jobs (e.g., future order confirmation emails) have a working execution path from day one.

#### Acceptance Criteria

1: `config/application.rb` (or environment configs) sets `config.active_job.queue_adapter = :sidekiq`.
2: `config/sidekiq.yml` and Redis connection config read the Redis URL from an environment variable matching the docker-compose `redis` service.
3: A `worker` service in `docker-compose.yml` runs `bundle exec sidekiq` against the same codebase as `web`.
4: A trivial smoke-test job (e.g., `HealthCheckJob`) can be enqueued and is observed to execute successfully against the dockerized Redis/Sidekiq, verified via a job spec using `ActiveJob::TestHelper`.

### Story 1.6 Health-Check Route

As an operator,
I want a `/up` (or `/health`) route that verifies the app, database, and Redis connections,
so that I have a deployable, observable signal that the foundation actually works end-to-end.

#### Acceptance Criteria

1: A `GET /up` route returns HTTP 200 with a simple body when the app, Postgres, and Redis connections are all healthy.
2: The route returns a non-200 status if the database connection fails (verified via a request spec that stubs a connection failure).
3: The route requires no authentication.
4: A request spec covers both the healthy and unhealthy paths.

### Story 1.7 Baseline CI Pipeline (Lint + Test)

As a developer,
I want a GitHub Actions workflow that runs RuboCop and the RSpec suite on every push/PR,
so that regressions are caught automatically before Epic 6 adds the Brakeman security gate.

#### Acceptance Criteria

1: `.github/workflows/ci.yml` runs on `push` and `pull_request`, using `ruby/setup-ruby` with bundler cache enabled.
2: The workflow spins up Postgres and Redis services needed for the test suite to run in CI.
3: The workflow runs `bundle exec rubocop` and `bundle exec rspec`, failing the job if either fails.
4: The workflow is verified green on a test branch/PR before being considered complete.

## Epic 2 Multi-Tenant Seller Onboarding

**Goal:** Estabelecer a fronteira de tenant que todo o restante da aplicação depende: vendedores se cadastram, ganham uma loja própria com slug único, e acessam um painel administrativo restrito àquela loja.

### Story 2.1 Shop Model and Tenant Scoping Infrastructure

As a developer,
I want a `Shop` model and the `acts_as_tenant` configuration wired into `ApplicationController`,
so that every tenant-scoped model created in later epics automatically inherits data isolation.

#### Acceptance Criteria

1: `Shop` model exists with `name`, `slug` (unique, indexed, URL-safe format validated).
2: `acts_as_tenant` is configured with `Shop` as the tenant class.
3: `ApplicationController` resolves the current tenant from `params[:shop_slug]` via `set_current_tenant_through_filter`, raising a 404 (not a 500) when the slug doesn't match any `Shop`.
4: A request spec verifies that visiting a route with an invalid `shop_slug` returns 404.

### Story 2.2 Seller Registration Creates a Shop

As a prospective seller,
I want to register an account and have a shop automatically created for me,
so that I can start managing my own store immediately after signing up.

#### Acceptance Criteria

1: A `Shops::Register` Interactor encapsulates: create `User` with `role: seller`, create associated `Shop` with a slug derived from the shop name (uniqueness enforced, suffixing if needed), wrapped in a database transaction.
2: The seller registration form collects shop name in addition to standard Devise fields.
3: On success, the seller is signed in and redirected to their shop's admin dashboard (`/:shop_slug/admin`).
4: A feature spec (Capybara) covers the full registration-to-dashboard-redirect flow.
5: A failure in shop creation rolls back the user creation (no orphaned `User` without a `Shop`).

### Story 2.3 Seller Admin Dashboard Shell

As a seller,
I want a dashboard page scoped to my own shop,
so that I have a starting point to manage my store before product/order features exist.

#### Acceptance Criteria

1: `/:shop_slug/admin` route exists, requiring authentication and `role: seller`, and requiring `current_user.shop_id == current Shop.id` (a seller cannot view another shop's admin area even if authenticated).
2: Attempting to access another shop's admin area as an authenticated seller returns 403 (via CanCanCan `Ability`/`authorize!`).
3: The dashboard renders placeholder sections for "Products" and "Orders" (populated in later epics).
4: A request spec verifies the cross-tenant access denial (403) explicitly.

### Story 2.4 Ability Rules for Seller/Shop Ownership

As a developer,
I want `Ability` rules that scope seller permissions to their own `Shop`,
so that authorization and tenant isolation work together consistently across the app.

#### Acceptance Criteria

1: `Ability` grants sellers `:manage` on resources where `shop_id == user.shop_id` (pattern to be reused by `Product`/`Order` in later epics).
2: `Ability` denies sellers any action on resources belonging to a different `shop_id`.
3: A model/unit spec for `Ability` verifies both the grant and the denial case using a stub/double resource.

## Epic 3 Product Catalog Management

**Goal:** Permitir que vendedores administrem seu catálogo de produtos dentro do isolamento de tenant já estabelecido, e que clientes visualizem uma vitrine pública por loja.

### Story 3.1 Product Model with Tenant Scoping

As a developer,
I want a `Product` model that uses `acts_as_tenant(:shop)`,
so that every query automatically scopes to the current shop without manual filtering.

#### Acceptance Criteria

1: `Product` has `shop_id`, `name`, `description`, `price_cents` (integer), `sku`, `active` (boolean, default true).
2: `Product` declares `acts_as_tenant(:shop)`.
3: A model spec verifies that, with `ActsAsTenant.current_tenant` set to Shop A, `Product.all` does not return Shop B's products even when both exist in the database.

### Story 3.2 Seller Product CRUD

As a seller,
I want to create, edit, list, and deactivate products in my shop's admin area,
so that I can manage what I'm selling.

#### Acceptance Criteria

1: `/:shop_slug/admin/products` supports index, new/create, edit/update, and a deactivate action (soft delete via `active: false`, not a hard destroy).
2: All actions are authorized via `Ability` (`can :manage, Product, shop_id: user.shop_id`).
3: Attempting to edit another shop's product (by guessing an ID) returns 404/403, verified by a request spec.
4: A feature spec covers creating a product through the form and seeing it appear in the index.

### Story 3.3 Public Storefront Product Listing

As a customer,
I want to browse a shop's public product listing,
so that I can find items to buy before any cart functionality exists.

#### Acceptance Criteria

1: `/:shop_slug/produtos` is a public (no auth required) route listing only `active: true` products for that shop.
2: Inactive products and products from other shops never appear, verified by a feature spec with multiple shops/products fixtures.
3: Each product links to a detail page (`/:shop_slug/produtos/:id`) showing full description and price.

## Epic 4 Shopping Cart

**Goal:** Permitir que clientes montem um carrinho de compras por loja, com interações fluidas via Turbo, preparando o terreno para o checkout.

### Story 4.1 Cart and CartItem Models

As a developer,
I want `Cart` and `CartItem` models scoped per shop,
so that a customer's cart contents are isolated to a single store.

#### Acceptance Criteria

1: `Cart` has `shop_id`, `user_id` (nullable, for guest carts identified by session token).
2: `CartItem` has `cart_id`, `product_id`, `quantity`, `unit_price_cents` (snapshot taken at add-time, not recalculated from `Product#price_cents` later).
3: A model spec verifies that adding the same product twice increments `quantity` rather than creating a duplicate row.

### Story 4.2 Add to Cart via Turbo

As a customer,
I want to add a product to my cart from the storefront without a full page reload,
so that browsing and shopping feels fast and modern.

#### Acceptance Criteria

1: A `Cart::AddItem` Interactor handles validation (product belongs to the shop, is active) and persistence.
2: The "Add to Cart" action uses a Turbo Frame/Stream to update the cart icon/count without a full page navigation.
3: A feature spec (Capybara, JS driver) verifies adding an item updates the visible cart count without a page reload assertion failing.
4: Adding a product from a different shop than the one in context is rejected (validated by a request/feature spec).

### Story 4.3 View and Update Cart

As a customer,
I want to view my cart and update quantities or remove items,
so that I can adjust my order before checking out.

#### Acceptance Criteria

1: `/:shop_slug/cart` shows current items, quantities, line subtotals, and a grand total.
2: Quantity can be updated inline (Turbo Stream update) and removing an item updates the total without a full reload.
3: An empty cart shows a clear empty-state message instead of an empty table.
4: A feature spec covers update-quantity and remove-item flows.

## Epic 5 Checkout & Orders

**Goal:** Permitir que o cliente finalize a compra criando um pedido imutável, e que o vendedor visualize os pedidos recebidos em sua loja — fechando o ciclo de valor do MVP.

### Story 5.1 Order and LineItem Models

As a developer,
I want `Order` and `LineItem` models that snapshot price/quantity at checkout time,
so that historical orders remain accurate even if product prices change later.

#### Acceptance Criteria

1: `Order` has `shop_id`, `user_id` (buyer, nullable for guest checkout if supported), `status` (enum: `pending`, `paid`, `fulfilled`, `cancelled`), `total_cents`.
2: `LineItem` has `order_id`, `product_id`, `quantity`, `unit_price_cents` (copied from the `CartItem` at checkout time).
3: A model spec verifies that changing a `Product`'s `price_cents` after an order is placed does not alter the `LineItem`'s stored `unit_price_cents`.

### Story 5.2 Checkout Flow Creates an Order

As a customer,
I want to convert my cart into a finalized order,
so that my purchase is recorded and the seller is notified.

#### Acceptance Criteria

1: A `Checkout::CreateOrder` Interactor: validates the cart is non-empty, creates `Order` + `LineItem`s from current `CartItem`s within a transaction, clears the cart on success, sets `status: pending`.
2: On success, the customer is redirected to an order confirmation page showing the order summary.
3: A `OrderConfirmationJob` (Sidekiq) is enqueued to send a confirmation notification (email delivery itself can be a stub/log-based `ActionMailer` preview in MVP).
4: A feature spec covers the full cart-to-confirmation flow, including verifying the job was enqueued (`ActiveJob::TestHelper`).
5: Checkout with an empty cart is rejected with a clear error message, not a 500.

### Story 5.3 Seller Order Visibility

As a seller,
I want to see orders placed in my shop,
so that I know what to fulfill.

#### Acceptance Criteria

1: `/:shop_slug/admin/orders` lists orders for the current shop only (tenant-scoped via `acts_as_tenant`), ordered most-recent-first.
2: Each order row links to a detail view showing line items, quantities, and total.
3: A request spec verifies a seller cannot view another shop's orders by guessing an order ID (403/404).

## Epic 6 CI/CD & Security Gate

**Goal:** Endurecer o pipeline de CI já estabelecido na Epic 1 com um gate de segurança real, agora que existe superfície de código de aplicação (models, controllers, Interactors) para o Brakeman analisar de forma significativa.

### Story 6.1 Brakeman Security Gate in CI

As a developer,
I want the CI pipeline to run Brakeman and fail the build on high/critical findings,
so that security regressions are caught before merge, not after deploy.

#### Acceptance Criteria

1: `.github/workflows/ci.yml` adds a `bundle exec brakeman -A -q --exit-on-warn --confidence-level=2` (or equivalent threshold) step.
2: The job fails the workflow when Brakeman finds confidence-level findings at or above the configured threshold.
3: Any pre-existing findings as of this story are either fixed or explicitly added to a documented Brakeman ignore file (`config/brakeman.ignore`) with a one-line justification per ignored finding — not silently suppressed.
4: The workflow is verified to actually fail on a deliberately introduced vulnerable code snippet in a throwaway test branch, then verified green after removing it.

### Story 6.2 CI Status Visibility and Branch Protection Note

As a maintainer,
I want CI status clearly visible and documented as a required check,
so that the Brakeman gate cannot be silently bypassed.

#### Acceptance Criteria

1: README (or `docs/`) documents that the `ci` workflow (lint, rspec, brakeman) is expected to be set as a required status check for the default branch (actual GitHub branch protection configuration is a `@devops`-owned, repo-admin action outside this story's scope).
2: The CI workflow name/job names are stable and documented so they can be referenced when configuring branch protection.

## Checklist Results Report

PRD elaborado a partir das decisões já validadas com o usuário em fase de planejamento (multi-tenancy via `acts_as_tenant`, roteamento por path, stack obrigatória, 6 epics). Checklist formal do `@po` (`po-master-checklist.md`) e validação ponto-a-ponto de cada epic/story ainda devem ser executados antes do início da implementação de cada epic, conforme o Story Development Cycle.

## Next Steps

### UX Expert Prompt

Não aplicável nesta fase — UI é server-rendered com Bootstrap padrão, sem necessidade de especificação visual dedicada para o MVP.

### Architect Prompt

@architect: usando este PRD (`docs/prd.md`) como entrada, produza `docs/architecture.md` definindo a topologia do Docker Compose (web/db/redis/worker), a estrutura de diretórios para Interactors (`app/interactors`), o mecanismo de resolução de tenant (`acts_as_tenant` + `before_action`), a convenção de rotas com `shop_slug`, e a localização/estrutura da classe `Ability` do CanCanCan — servindo de base para `@data-engineer` (modelagem de dados) e para as stories de cada epic.
