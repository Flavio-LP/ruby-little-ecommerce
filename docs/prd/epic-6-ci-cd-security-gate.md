# Epic 6 CI/CD & Security Gate

**Goal:** Endurecer o pipeline de CI já estabelecido na Epic 1 com um gate de segurança real, agora que existe superfície de código de aplicação (models, controllers, Interactors) para o Brakeman analisar de forma significativa.

## Story 6.1 Brakeman Security Gate in CI

As a developer,
I want the CI pipeline to run Brakeman and fail the build on high/critical findings,
so that security regressions are caught before merge, not after deploy.

### Acceptance Criteria

1: `.github/workflows/ci.yml` adds a `bundle exec brakeman -A -q --exit-on-warn --confidence-level=2` (or equivalent threshold) step.
2: The job fails the workflow when Brakeman finds confidence-level findings at or above the configured threshold.
3: Any pre-existing findings as of this story are either fixed or explicitly added to a documented Brakeman ignore file (`config/brakeman.ignore`) with a one-line justification per ignored finding — not silently suppressed.
4: The workflow is verified to actually fail on a deliberately introduced vulnerable code snippet in a throwaway test branch, then verified green after removing it.

## Story 6.2 CI Status Visibility and Branch Protection Note

As a maintainer,
I want CI status clearly visible and documented as a required check,
so that the Brakeman gate cannot be silently bypassed.

### Acceptance Criteria

1: README (or `docs/`) documents that the `ci` workflow (lint, rspec, brakeman) is expected to be set as a required status check for the default branch (actual GitHub branch protection configuration is a `@devops`-owned, repo-admin action outside this story's scope).
2: The CI workflow name/job names are stable and documented so they can be referenced when configuring branch protection.
