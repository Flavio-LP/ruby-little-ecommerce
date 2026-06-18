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

Pipeline em `.github/workflows/ci.yml`, com 4 jobs independentes em todo push/PR:

| Job | O que faz |
|---|---|
| `scan_ruby` | `bin/brakeman -i config/brakeman.ignore --confidence-level=2` — gate de segurança, bloqueia merge em findings não ignorados |
| `scan_js` | `bin/importmap audit` — vulnerabilidades em dependências JS |
| `lint` | `bundle exec rubocop` |
| `test` | `bundle exec rspec` (Postgres + Redis como services) |

Findings do Brakeman aceitos como risco conhecido (com justificativa) ficam em `config/brakeman.ignore` — nunca suprimir um finding sem uma nota explicando o motivo. Verificado localmente (introduzindo e removendo uma vulnerabilidade de SQL injection de propósito) que o job `scan_ruby` falha (`exit 3`) com uma vulnerabilidade real e passa (`exit 0`) sem ela.

**Ação pendente para `@devops`:** configurar os 4 jobs acima (`scan_ruby`, `scan_js`, `lint`, `test`) como required status checks na branch `main` no GitHub (Settings → Branches → Branch protection rules) — exige acesso de admin do repositório e `gh auth`/acesso à UI do GitHub, fora do escopo de execução deste agente.
