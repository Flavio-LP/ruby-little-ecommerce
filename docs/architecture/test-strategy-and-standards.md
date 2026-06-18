# Test Strategy and Standards

## Testing Philosophy

- **Approach:** Test-after para a maior parte das stories, mas toda Acceptance Criteria do PRD deve ter um teste automatizado correspondente antes do QA gate.
- **Coverage Goals:** sem percentual rígido — foco em cobrir todos os fluxos críticos do PRD (cadastro de vendedor, CRUD de produto, carrinho, checkout) com testes de feature, e toda regra de negócio em Interactors com testes unitários.
- **Test Pyramid:** maioria unit (models/interactors) + request specs (autorização/tenant) + feature specs (Capybara) para os fluxos ponta-a-ponta.

## Test Types and Organization

- **Unit Tests:** RSpec, `spec/models/`, `spec/interactors/`; mocking via RSpec doubles/`instance_double`.
- **Integration/Request Tests:** `spec/requests/`, focados em autorização (403/404 cross-tenant) e contratos de rota.
- **Feature Tests:** Capybara, `spec/features/`, cobrindo os fluxos ponta-a-ponta do PRD.

## Test Data Management

- **Strategy:** Factories (gem `factory_bot_rails`, adicionada na Story 1.2) em `spec/factories/`.
- **Cleanup:** transação por teste (padrão RSpec + Rails), banco de teste dedicado via `docker-compose` (`db` service, database `*_test`).

## Continuous Testing

- **CI Integration:** `bundle exec rspec` na Epic 1 (Story 1.7); `bundle exec brakeman` adicionado na Epic 6 (Story 6.1) como gate de segurança bloqueante.
