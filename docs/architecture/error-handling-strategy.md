# Error Handling Strategy

## General Approach

- **Error Model:** Exceções Ruby padrão + `Interactor::Failure` (via `context.fail!`) para falhas de regra de negócio dentro de Interactors.
- **Exception Hierarchy:** `CanCan::AccessDenied` tratado globalmente em `ApplicationController` (redirect + flash); `ActiveRecord::RecordNotFound` (incluindo tenant/slug inválido) resulta em 404 padrão do Rails.
- **Error Propagation:** Controllers nunca deixam exceções de Interactor "vazarem" como 500 — sempre verificam `result.success?` e renderizam erro amigável.

## Logging Standards

- **Library:** Rails logger padrão (`Rails.logger`), formato texto em dev, estruturado (tags) em produção (já gerenciado pelo setup Kamal existente).
- **Required Context:** nunca logar `encrypted_password`, tokens Devise, ou dados de cartão (não aplicável neste MVP, sem gateway de pagamento real).

## Error Handling Patterns

- **Business Logic Errors:** Interactors retornam `context.fail!(error: "mensagem")`; controller renderiza a mensagem via flash/erro de formulário — nunca um 500.
- **Data Consistency:** todo Interactor que grava múltiplos models (ex.: `Shops::Register`, `Checkout::CreateOrder`) executa dentro de `ActiveRecord::Base.transaction`.
