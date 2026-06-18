# Goals and Background Context

## Goals

- Permitir que múltiplos vendedores (tenants) operem lojas independentes na mesma plataforma, sem visibilidade cruzada de dados.
- Oferecer um catálogo de produtos simples que cada vendedor administra de forma isolada.
- Permitir que clientes naveguem por uma loja específica, montem um carrinho e finalizem a compra (checkout).
- Garantir que toda a stack (Docker, Rails, Devise/CanCanCan, RSpec/Capybara, Sidekiq/Redis, PostgreSQL) esteja operacional desde o primeiro epic, com gate de segurança (Brakeman) no pipeline de CI.
- Entregar o MVP em incrementos verticais e testáveis, sem deixar infraestrutura/segurança como tarefas de última hora.

## Background Context

Este projeto nasce como uma plataforma de e-commerce inspirada no modelo Shopify: em vez de um único catálogo, a aplicação hospeda diversas lojas (tenants) simultaneamente, cada uma pertencente a um vendedor que gerencia seus próprios produtos e recebe seus próprios pedidos. Não existe código de produto ainda — apenas o scaffold padrão do Rails 8 — então o MVP precisa estabelecer a fundação (Docker, autenticação, isolamento multi-tenant) antes de qualquer feature de catálogo/carrinho/checkout.

A escolha de isolamento por linha (`acts_as_tenant` com `shop_id`) em vez de isolamento por schema (Apartment) foi feita para manter a complexidade operacional baixa (sem N migrations por schema, sem necessidade de trocar contexto de schema em jobs do Sidekiq), adequada ao escopo "e-commerce simples" solicitado. O roteamento por path (`/:shop_slug/...`) foi escolhido sobre subdomínio para evitar configuração de DNS/hosts em ambiente Docker local.

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2026-06-17 | 0.1 | Versão inicial do PRD, criada a partir da descrição do usuário e decisões de arquitetura (multi-tenancy, roteamento) aprovadas em plano. | @pm (Morgan) |
