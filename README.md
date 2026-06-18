# Web E-Commerce (Multi-Tenant)

Plataforma de e-commerce multi-tenant (estilo Shopify): cada vendedor tem sua própria loja (`/:shop_slug/...`), com catálogo, carrinho e checkout isolados por tenant.

Documentação completa:
- [`docs/prd.md`](docs/prd.md) — requisitos e épicos do produto
- [`docs/architecture.md`](docs/architecture.md) — arquitetura técnica detalhada
- [`docs/framework/tech-stack.md`](docs/framework/tech-stack.md) — stack
- [`docs/stories/`](docs/stories/) — stories de desenvolvimento por épico

## Stack

- **Ruby** 3.2.8 / **Rails** 8.0.5
- **PostgreSQL 16** — banco de dados principal
- **Redis 7** — cache, jobs (Sidekiq)
- **Sidekiq** — processamento de jobs em background
- **Devise** — autenticação de usuários (vendedores)
- **CanCanCan** — autorização baseada em abilities
- **acts_as_tenant** — escopo de tenant (multi-loja) por `shop`
- **Interactor** — objetos de caso de uso (`app/interactors/`)
- **Turbo + Stimulus + Importmap** — frontend sem build JS (Hotwire)
- **Propshaft** — asset pipeline
- **RSpec + Capybara + Cuprite + FactoryBot** — testes
- **Brakeman + bin/importmap audit + Rubocop (omakase)** — segurança e lint
- **Kamal** — deploy de produção (não configurado com servidor real ainda)

## Funcionalidades

- Cadastro de vendedor cria automaticamente uma loja (`Shop`) com slug único
- Catálogo de produtos por loja, com CRUD para o vendedor (`/:shop_slug/admin/products`)
- Vitrine pública por loja (`/:shop_slug/produtos`)
- Carrinho de compras via Turbo Streams (sem reload de página)
- Checkout que gera `Order` + `LineItem`s, com confirmação
- Painel administrativo do vendedor: dashboard, pedidos, produtos — visível apenas para o dono da loja (isolamento de tenant garantido por `acts_as_tenant` + `CanCanCan`)
- Health check em `/up` (verifica app, banco e Redis)

## Como rodar — Docker Compose (recomendado)

Pré-requisitos: Docker Engine + Docker Compose v2.

Um `Makefile` na raiz encapsula os comandos mais usados (`make help` lista todos):

```bash
make build      # build das imagens (web, worker)
make up         # sobe o stack em foreground (web, db, redis, worker)
make up-d       # mesma coisa, mas detached
make ps         # status dos containers
make logs       # logs (make logs s=web para um serviço específico)
make console    # bin/rails console dentro do container web
make migrate    # bin/rails db:migrate
make test       # bundle exec rspec
make shell      # shell (bash) no container web
make down       # para o stack
make clean      # para o stack e remove volumes (postgres_data, bundle_cache)
```

Sem o Makefile, os comandos equivalentes via `docker compose`:

```bash
docker compose up                                  # build + start
docker compose exec web bundle exec rspec           # suíte de testes
docker compose exec web bin/rails console            # console Rails
docker compose exec web bin/rails db:migrate          # migrations
docker compose exec web bash                          # shell no container
```

O serviço `web` cria/migra o banco automaticamente no boot (`bin/dev-server`). Dados do Postgres persistem no volume nomeado `postgres_data` entre restarts.

Serviços (`docker-compose.yml`):

| Serviço | Imagem/build | Porta no host (padrão) | Papel |
|---|---|---|---|
| `web` | `Dockerfile.dev` | `3010` → `3000` no container | Rails (Puma) |
| `db` | `postgres:16` | `5434` → `5432` no container | Banco de dados |
| `redis` | `redis:7` | `6380` → `6379` no container | Cache + fila do Sidekiq |
| `worker` | `Dockerfile.dev` | — (sem porta exposta) | Sidekiq (jobs em background) |

As portas do host são configuráveis via variáveis de ambiente, caso `3010`/`5434`/`6380` também já estejam em uso: crie um `.env` na raiz com `WEB_PORT`, `DB_PORT` e/ou `REDIS_PORT` (ex.: `WEB_PORT=4000`) antes de rodar `docker compose up` — o Compose lê o `.env` automaticamente.

Acesse `http://localhost:3010` para a vitrine e `http://localhost:3010/up` para o health-check.

## Dados e credenciais de demonstração

A task `lib/tasks/demo_data.rake` popula o banco com 3 lojas, 2 produtos em cada uma, 1 administrador por loja e 2 clientes — útil para testar login e navegação sem precisar cadastrar nada manualmente:

```bash
make console   # ou: docker compose exec web bin/rails console
docker compose exec web bin/rails demo:seed
```

A senha de todas as contas geradas é `password123`. É seguro rodar a task mais de uma vez (idempotente via `find_or_create_by!`).

| Papel | Loja | E-mail | Acesso |
|---|---|---|---|
| Administrador | Loja Aurora | `admin-loja-aurora@example.com` | `/loja-aurora/admin` |
| Administrador | Loja Boreal | `admin-loja-boreal@example.com` | `/loja-boreal/admin` |
| Administrador | Loja Cedro | `admin-loja-cedro@example.com` | `/loja-cedro/admin` |
| Cliente | — (compra em qualquer loja) | `cliente1@example.com` | `/` |
| Cliente | — (compra em qualquer loja) | `cliente2@example.com` | `/` |

Faça login em `http://localhost:3010/users/sign_in` com um desses e-mails e a senha `password123`. Administradores são redirecionados ao painel da própria loja; clientes caem na lista de lojas (`/`) e podem navegar e comprar em qualquer uma delas.

## Como rodar — sem Docker (Ruby local)

Requer Ruby 3.2.8 e PostgreSQL/Redis rodando localmente, com `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `REDIS_URL` configurados via ambiente conforme `config/database.yml`.

```bash
bundle install
bin/rails db:prepare
bundle exec rspec
bin/rails server
```

## Build de produção

O `Dockerfile` (raiz) gera uma imagem standalone de produção, pensada para build/run manual ou deploy via Kamal — não usa Docker Compose.

```bash
make prod-build   # docker build -t web_e_commerce .
make prod-run     # docker run -d -p 80:80 -e RAILS_MASTER_KEY=... web_e_commerce
make prod-logs    # docker logs -f web_e_commerce
make prod-stop    # docker stop + rm
```

`prod-run` lê a master key de `config/master.key` automaticamente; para sobrescrever, use `RAILS_MASTER_KEY=<valor> make prod-run`.

Deploy real (múltiplos servidores, SSL, registry) é feito via Kamal (`config/deploy.yml`), mas o arquivo ainda está com placeholders (`192.168.0.1`, `your-user`) e precisa ser configurado antes de um `kamal deploy` funcionar.

## Testes

A suíte usa RSpec, organizada por camada:

| Diretório | O que cobre |
|---|---|
| `spec/models/` | Validações, associações, regras de negócio nos models (inclui `ability_spec.rb` para CanCanCan) |
| `spec/interactors/` | Casos de uso isolados (`Carts::AddItem`, `Checkout::CreateOrder`, `Shops::Register`) |
| `spec/jobs/` | Jobs em background (Sidekiq) |
| `spec/requests/` | Testes de integração HTTP (controllers, autenticação, isolamento de tenant) |
| `spec/features/` | Testes end-to-end via Capybara (fluxos completos: cadastro, carrinho, checkout) |

```bash
bundle exec rspec                       # suíte completa
bundle exec rspec spec/models           # só unit tests de models
bundle exec rspec spec/interactors spec/jobs   # unit tests de interactors + jobs
```

## CI/CD

Pipeline em [`.github/workflows/ci.yml`](.github/workflows/ci.yml), disparada em todo push/PR para `main` e via `workflow_dispatch`, com 4 jobs independentes em paralelo:

| Job | O que faz |
|---|---|
| `scan_ruby` | `bin/brakeman -i config/brakeman.ignore --confidence-level=2` — gate de segurança, bloqueia merge em findings não ignorados |
| `scan_js` | `bin/importmap audit` — vulnerabilidades em dependências JS |
| `lint` | `bundle exec rubocop` (estilo omakase do Rails) |
| `test` | `bundle exec rspec` — suíte completa (unit + request + feature specs), com Postgres e Redis como services do GitHub Actions |

Findings do Brakeman aceitos como risco conhecido (com justificativa) ficam em `config/brakeman.ignore` — nunca suprimir um finding sem uma nota explicando o motivo.

**Ação pendente para `@devops`:** configurar os 4 jobs acima (`scan_ruby`, `scan_js`, `lint`, `test`) como required status checks na branch `main` no GitHub (Settings → Branches → Branch protection rules) — exige acesso de admin do repositório e `gh auth`/acesso à UI do GitHub, fora do escopo de execução deste agente.

## Estrutura do projeto

```
app/
├── controllers/         # admin/ (vendedor), public/ (vitrine), users/ (Devise)
├── interactors/         # carts/, checkout/, shops/ — casos de uso isolados
├── jobs/                # Sidekiq jobs
├── models/              # Shop, Product, Cart, CartItem, Order, LineItem, User
└── views/                # ERB, organizadas por controller

docs/
├── prd/                 # requisitos e épicos
├── architecture/        # arquitetura detalhada (schema, segurança, workflows)
├── framework/           # tech stack, coding standards
└── stories/             # stories de desenvolvimento (1.1, 2.3, etc.)

spec/                     # ver seção Testes acima
config/deploy.yml         # configuração Kamal (produção)
docker-compose.yml         # ambiente de desenvolvimento
Dockerfile / Dockerfile.dev # imagens de produção / desenvolvimento
Makefile                   # atalhos para docker compose e build/run de produção
```
