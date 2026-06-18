# Epic 1 Foundation & Infrastructure

**Goal:** Estabelecer toda a base técnica do projeto — ambiente containerizado, autenticação, autorização, suíte de testes e pipeline de CI — entregando como funcionalidade inicial uma rota de health-check verificável, para que todos os epics seguintes partam de uma fundação estável e testável.

## Story 1.1 Docker Compose Development Environment

As a developer,
I want a `docker-compose.yml` that boots the Rails app, PostgreSQL, and Redis with a single command,
so that anyone can start a working local environment without manual setup.

### Acceptance Criteria

1: `docker compose up` builds and starts `web`, `db` (Postgres), and `redis` services successfully.
2: A development-specific `Dockerfile.dev` (or equivalent multi-stage target) is used for the `web` service, distinct from the existing production `Dockerfile`.
3: `config/database.yml` is configured to read connection settings from environment variables provided by `docker-compose.yml`.
4: Database data persists across container restarts via a named volume.
5: A `README` section (or `docs/` note) documents how to start the environment and run common commands (`bundle exec rspec`, `rails console`) inside the container.

## Story 1.2 Core Gem Stack Installation

As a developer,
I want the Gemfile updated with `interactor`, `devise`, `cancancan`, `acts_as_tenant`, `sidekiq`, `redis`, `bootstrap`, `rspec-rails`, and `capybara`,
so that the application has the foundation libraries available for every subsequent epic.

### Acceptance Criteria

1: `Gemfile` includes `interactor`, `devise`, `cancancan`, `acts_as_tenant`, `sidekiq`, `redis`, `bootstrap` (or equivalent asset integration) in the main group, and `rspec-rails`, `capybara` in the `:development, :test` group.
2: `bundle install` completes successfully inside the Docker `web` service.
3: Default Rails Minitest scaffolding (`test/` directory, `Rails.application.config.generators.test_framework`) is removed/replaced in favor of RSpec.
4: `rails generate rspec:install` has been run, producing `spec/spec_helper.rb` and `spec/rails_helper.rb` configured with Capybara feature spec support.

## Story 1.3 Devise Authentication Setup

As a developer,
I want Devise installed with a single `User` model that includes a `role` enum (`seller`/`customer`),
so that both sellers and customers can authenticate through the same mechanism while remaining distinguishable for authorization.

### Acceptance Criteria

1: `rails generate devise:install` and `rails generate devise User` have been run, producing migrations for the standard Devise fields.
2: `User` model has a `role` column (integer enum: `seller`, `customer`) with a non-null default and a database-level check/constraint or Rails validation enforcing one of the two values.
3: Devise views (registration, sessions) are generated and themed minimally with Bootstrap so they are usable, not just functional defaults.
4: A model spec verifies that a `User` cannot be saved without a valid `role`.

## Story 1.4 CanCanCan Authorization Skeleton

As a developer,
I want CanCanCan installed with an `Ability` class that branches on `User#role`,
so that authorization logic has a single, centralized location from the start of the project.

### Acceptance Criteria

1: `rails generate cancan:ability` has been run, producing `app/models/ability.rb`.
2: `Ability` defines distinct rule blocks for `role == "seller"` and `role == "customer"` (even if the rule sets are still empty/minimal placeholders pending Epic 2-5 models).
3: `ApplicationController` includes `CanCan::ControllerAdditions` and rescues `CanCan::AccessDenied` with a redirect + flash message.
4: A request spec verifies that an unauthorized action raises/handles `CanCan::AccessDenied` as expected.

## Story 1.5 Sidekiq and Redis Background Job Wiring

As a developer,
I want Sidekiq configured as the Active Job adapter, connected to the Redis service from docker-compose,
so that asynchronous jobs (e.g., future order confirmation emails) have a working execution path from day one.

### Acceptance Criteria

1: `config/application.rb` (or environment configs) sets `config.active_job.queue_adapter = :sidekiq`.
2: `config/sidekiq.yml` and Redis connection config read the Redis URL from an environment variable matching the docker-compose `redis` service.
3: A `worker` service in `docker-compose.yml` runs `bundle exec sidekiq` against the same codebase as `web`.
4: A trivial smoke-test job (e.g., `HealthCheckJob`) can be enqueued and is observed to execute successfully against the dockerized Redis/Sidekiq, verified via a job spec using `ActiveJob::TestHelper`.

## Story 1.6 Health-Check Route

As an operator,
I want a `/up` (or `/health`) route that verifies the app, database, and Redis connections,
so that I have a deployable, observable signal that the foundation actually works end-to-end.

### Acceptance Criteria

1: A `GET /up` route returns HTTP 200 with a simple body when the app, Postgres, and Redis connections are all healthy.
2: The route returns a non-200 status if the database connection fails (verified via a request spec that stubs a connection failure).
3: The route requires no authentication.
4: A request spec covers both the healthy and unhealthy paths.

## Story 1.7 Baseline CI Pipeline (Lint + Test)

As a developer,
I want a GitHub Actions workflow that runs RuboCop and the RSpec suite on every push/PR,
so that regressions are caught automatically before Epic 6 adds the Brakeman security gate.

### Acceptance Criteria

1: `.github/workflows/ci.yml` runs on `push` and `pull_request`, using `ruby/setup-ruby` with bundler cache enabled.
2: The workflow spins up Postgres and Redis services needed for the test suite to run in CI.
3: The workflow runs `bundle exec rubocop` and `bundle exec rspec`, failing the job if either fails.
4: The workflow is verified green on a test branch/PR before being considered complete.
