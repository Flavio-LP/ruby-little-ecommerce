# Technical Assumptions

## Repository Structure: Monorepo

Aplicação Rails única (monólito), sem necessidade de múltiplos repositórios para o MVP.

## Service Architecture

**Monolito Rails modular.** Um único processo web (Puma) servindo HTML, mais um processo worker (Sidekiq) consumindo a mesma base de código para jobs assíncronos. Multi-tenancy é tratada dentro do monólito via `acts_as_tenant` (escopo de dados), não via serviços separados por tenant. Esta decisão evita a complexidade operacional de microsserviços/schema-per-tenant, adequada ao escopo "e-commerce simples" do MVP.

## Testing Requirements

**Full Testing Pyramid (adaptado):** testes unitários (models, Interactors, Ability classes) + testes de feature end-to-end com RSpec + Capybara para os fluxos críticos (cadastro de vendedor, CRUD de produto, carrinho, checkout). Minitest padrão do Rails será removido em favor de RSpec na Epic 1.

## Additional Technical Assumptions and Requests

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
