# Infrastructure and Deployment

## Infrastructure as Code

- **Tool:** Docker Compose (desenvolvimento apenas — produção já usa Kamal, fora do escopo deste documento)
- **Location:** `docker-compose.yml` (raiz do projeto)
- **Approach:** 4 serviços (`web`, `db`, `redis`, `worker`), todos lendo `.env`/variáveis de ambiente para credenciais; volume nomeado para persistência do Postgres.

## Deployment Strategy

- **Strategy:** Fora do escopo do MVP (produção via Kamal já configurado no repo, não alterado por este trabalho).
- **CI/CD Platform:** GitHub Actions
- **Pipeline Configuration:** `.github/workflows/ci.yml`

## Environments

- **development:** Docker Compose local, dados de teste/seed.
- **test:** mesma infraestrutura, banco `*_test`, usado por RSpec/CI.
