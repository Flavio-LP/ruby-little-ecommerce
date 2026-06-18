# Tech Stack

> Fonte: `docs/architecture.md` — seção "Tech Stack". Carregado sempre por `@dev` (`devLoadAlwaysFiles` em `core-config.yaml`).

## Technology Stack Table

| Category | Technology | Version | Purpose | Rationale |
|---|---|---|---|---|
| Language | Ruby | 3.2.8 | Linguagem principal | Já fixada em `.ruby-version` |
| Framework | Rails | ~> 8.0.5 | Framework web | Já fixado no Gemfile |
| Database | PostgreSQL | 16 (imagem `postgres:16`) | Persistência primária | Mandatado pelo usuário; única fonte de dados |
| Cache/Queue Broker | Redis | 7 (imagem `redis:7`) | Broker do Sidekiq | Mandatado pelo usuário |
| Background Jobs | Sidekiq | ~> 7.x | Processamento assíncrono | Mandatado pelo usuário |
| Auth | Devise | ~> 4.9 | Autenticação | Mandatado pelo usuário |
| Authorization | CanCanCan | ~> 3.6 | Autorização | Mandatado pelo usuário |
| Multi-tenancy | acts_as_tenant | ~> 1.0 | Isolamento de dados por loja | Decisão aprovada em plano (ver PRD) |
| Business logic | interactor | ~> 3.1 | Service objects | Mandatado pelo usuário |
| CSS | Bootstrap | ~> 5.3 (via `bootstrap` gem + Sass) | Estilo | Mandatado pelo usuário |
| Frontend interaction | Turbo Rails / Stimulus | já no Gemfile | Navegação sem reload, JS pontual | Mandatado pelo usuário |
| Test framework | RSpec Rails | ~> 7.x | Testes unitários/request | Mandatado pelo usuário, substitui Minitest |
| Feature tests | Capybara | ~> 3.x | Testes end-to-end de feature | Mandatado pelo usuário |
| Test data | factory_bot_rails | ~> 6.x | Factories para specs | Padrão de mercado para RSpec |
| Security scan | Brakeman | já no Gemfile (dev/test) | SAST gate de CI | Mandatado pelo usuário |
| Containerization | Docker + Docker Compose | Docker Engine 24+, Compose v2 | Ambiente de desenvolvimento | Mandatado pelo usuário |
| CI/CD | GitHub Actions | — | Pipeline de lint/test/security | Repositório já hospedado no GitHub |

> `@dev` deve fixar a versão exata resolvida pelo `bundle install` no `Gemfile.lock` durante a Story 1.2.
