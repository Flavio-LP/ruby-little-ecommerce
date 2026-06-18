# Epic List

- **Epic 1: Foundation & Infrastructure** — Estabelecer o ambiente Docker Compose, a stack de gems (Devise, CanCanCan, Interactor, Sidekiq, RSpec/Capybara), e uma rota de health-check funcional, com CI básico de lint/test já operante desde o início.
- **Epic 2: Multi-Tenant Seller Onboarding** — Permitir que vendedores se cadastrem e tenham sua própria loja isolada (`Shop` + `shop_id`), com painel administrativo básico.
- **Epic 3: Product Catalog Management** — Permitir que vendedores gerenciem produtos dentro de sua loja e que clientes vejam a vitrine pública.
- **Epic 4: Shopping Cart** — Permitir que clientes montem um carrinho de compras por loja, com atualizações via Turbo.
- **Epic 5: Checkout & Orders** — Permitir que clientes finalizem a compra criando um pedido imutável, e que vendedores vejam os pedidos recebidos.
- **Epic 6: CI/CD & Security Gate** — Endurecer o pipeline de CI com o gate de segurança do Brakeman bloqueando merges com findings críticos, agora que existe código de aplicação real para escanear.
