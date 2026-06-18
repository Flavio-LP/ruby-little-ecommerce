# User Interface Design Goals

## Overall UX Vision

Interface simples e funcional, sem necessidade de SPA: páginas renderizadas no servidor com Bootstrap para grid/componentes e Turbo Drive/Frames para tornar ações como adicionar ao carrinho ou atualizar quantidade fluidas, sem reload completo da página.

## Key Interaction Paradigms

- Navegação tradicional por links/formulários Rails, com Turbo interceptando para evitar reloads.
- Ações de carrinho (adicionar/remover/atualizar) via Turbo Frames/Streams, atualizando apenas a seção relevante da página.
- Painel do vendedor como uma área autenticada distinta da vitrine pública, ambas sob o mesmo `shop_slug`.

## Core Screens and Views

- Tela de cadastro/login (vendedor e cliente)
- Dashboard do vendedor (lista de produtos, lista de pedidos)
- Formulário de produto (criar/editar)
- Vitrine pública da loja (lista de produtos ativos)
- Página de detalhe do produto
- Carrinho de compras
- Checkout / confirmação de pedido
- Rota de health-check (sem UI, retorno JSON/texto simples)

## Accessibility: None

MVP não exige conformidade WCAG formal, mas deve seguir boas práticas básicas de HTML semântico (labels em formulários, contraste mínimo do Bootstrap padrão).

## Branding

Nenhuma identidade visual definida ainda — usar o tema padrão do Bootstrap sem customização nesta fase.

## Target Device and Platforms: Web Responsive

Web responsivo (desktop e mobile via grid do Bootstrap), sem app nativo nesta fase.
