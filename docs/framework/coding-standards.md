# Coding Standards

> Fonte: `docs/architecture.md` — seção "Coding Standards". Carregado sempre por `@dev` (`devLoadAlwaysFiles` em `core-config.yaml`).

## Core Standards

- **Languages & Runtimes:** Ruby 3.2.8, Rails ~> 8.0.5 (ver `.ruby-version`/`Gemfile.lock`).
- **Style & Linting:** RuboCop (config `rubocop-rails-omakase`, já referenciada no Gemfile gerado pelo Rails 8).
- **Test Organization:** specs em `spec/`, espelhando a estrutura de `app/` (`spec/models`, `spec/requests`, `spec/features`, `spec/interactors`).

## Critical Rules

- **Tenant scoping é obrigatório, nunca manual:** todo model que pertence a uma loja DEVE declarar `acts_as_tenant(:shop)` — nunca filtrar por `shop_id` manualmente em uma query ad-hoc.
- **Lógica de negócio multi-step vai em Interactor, nunca no controller:** se uma ação envolve mais de uma escrita ou uma regra de negócio não-trivial, ela pertence a `app/interactors/`.
- **Autorização sempre via `Ability`/`authorize!`:** nunca `if current_user.role == "seller"` direto em controller/view para decidir permissão de ação.
- **Preço é sempre snapshot:** `CartItem#unit_price_cents` e `LineItem#unit_price_cents` nunca são recalculados a partir de `Product#price_cents` após a criação.
- **Nunca usar `Model.unscoped`/bypass de tenant sem justificativa explícita em comentário** — qualquer escape hatch do `acts_as_tenant` é uma exceção documentada, não o padrão.
- **Tenant é resolvido antes da autorização:** um `shop_slug` inválido deve resultar em 404 antes de qualquer checagem de `Ability` ser executada.
- **Strong Parameters sempre:** nenhum `params.permit!` genérico; todo `params` usado em query/criação passa por whitelist explícita.
- **Toda escrita multi-model em transação:** Interactors que gravam mais de um model (`Shops::Register`, `Checkout::CreateOrder`) usam `ActiveRecord::Base.transaction`.
