# Security

## Input Validation

- **Validation Location:** nos models (Active Record validations) e nos Interactors antes de qualquer escrita.
- **Required Rules:** todo `params` usado em uma query ou criação de registro passa por Strong Parameters; nenhum `params.permit!` genérico.

## Authentication & Authorization

- **Auth Method:** Devise (cookie de sessão padrão Rails).
- **Required Patterns:** toda ação de controller que modifica dados tenant-scoped passa por `authorize!` (CanCanCan) ANTES de qualquer leitura/escrita; tenant é resolvido antes da autorização.

## Secrets Management

- **Development:** variáveis de ambiente via `docker-compose.yml` / arquivo `.env` (não commitado).
- **Production:** `config/master.key`/Rails credentials, já no padrão do scaffold existente.
- **Code Requirements:** nunca hardcode de credenciais; nada de segredo em log.

## Dependency Security

- **Scanning Tool:** Brakeman (SAST, gate de CI na Epic 6); `bundle audit` pode ser adicionado como melhoria futura, fora do escopo do MVP.
