# Web E-Commerce (Multi-Tenant)

Plataforma de e-commerce multi-tenant (estilo Shopify): cada vendedor tem sua própria loja (`/:shop_slug/...`), com catálogo, carrinho e checkout isolados por tenant. Veja `docs/prd.md` e `docs/architecture.md` para o desenho completo.

## Ambiente de desenvolvimento (Docker Compose)

Pré-requisitos: Docker Engine + Docker Compose v2.

```bash
# build + start (web, db, redis, worker)
docker compose up

# em outro terminal, depois do primeiro boot:
docker compose exec web bundle exec rspec       # suíte de testes
docker compose exec web bin/rails console        # console Rails
docker compose exec web bin/rails db:migrate      # migrations
docker compose exec web bash                      # shell no container
```

O serviço `web` cria/migra o banco automaticamente no boot (`bin/dev-server`). Dados do Postgres persistem no volume nomeado `postgres_data` entre restarts.

Serviços:
- `web` — Rails (Puma), porta `3000`
- `db` — PostgreSQL 16, porta `5432`
- `redis` — Redis 7, porta `6379`
- `worker` — Sidekiq (background jobs)

Acesse `http://localhost:3000/up` para o health-check.

## Sem Docker (Ruby local)

Requer Ruby 3.2.8 e PostgreSQL/Redis rodando localmente, com `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `REDIS_URL` configurados via ambiente conforme `config/database.yml`.

```bash
bundle install
bin/rails db:prepare
bundle exec rspec
bin/rails server
```

## CI

Pipeline em `.github/workflows/ci.yml`: `bundle exec rubocop` + `bundle exec rspec` em todo push/PR. O gate de segurança Brakeman (`bundle exec brakeman`) é adicionado como check obrigatório a partir da Epic 6 — configurar como required status check na branch padrão no GitHub (ação de admin do repositório, fora do escopo deste código).
