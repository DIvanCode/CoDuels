# CoDuels delivery map

## Contents

- [Repository model](#repository-model)
- [Component validation](#component-validation)
- [Component production delivery](#component-production-delivery)
- [Ansible components](#ansible-components)
- [GitHub configuration](#github-configuration)

## Repository model

- Root `CoDuels` owns `Docs/`, shared agent instructions, and the Backend/Frontend submodule revisions tracked by the superproject. It has no GitHub Actions workflows and does not release components.
- `Backend` and `Frontend` are submodules with independent pull-request workflows that validate and then deploy the pull-request revision to production.
- `Backend/Taski/tasks` is itself a project-owned submodule. Its task-storage deployment runs from that repository on pushes to `master`.
- `Backend/filestorage` has its own pull-request Go test workflow and no production deployment workflow.

## Component validation

### Backend validation gates

- `duely_pull_request.yml`: .NET 8 Release tests and PR coverage report for `Duely/**`, followed by the Duely build and deployment.
- `exesh_pull_request.yml`: Go 1.24 tests plus a Django dashboard system check for `Exesh/**`, followed by the Exesh build and deployment.
- `taski_pull_request.yml`: Go 1.24 tests for Taski application changes, excluding the nested tasks submodule, followed by the Taski build and deployment.
- `e2e_tests_pull_request.yml`: an independent isolated Docker Compose Taski-Exesh A+B acceptance flow for `Taski/**` (excluding `Taski/tasks`) and `Exesh/**`. It checks out recursive submodules and runs the same `e2e/taski-exesh/run.sh` entry point used locally. Its result is not listed in the Taski or Exesh build dependencies, and its current paths do not include scenario-only or related root Compose/submodule changes.
- `analyzer_pull_request.yml`: Python 3.10 dependency install, syntax compilation, and baseline/production model training for `Analyzer/**`, followed by another production-model training pass, image build, and deployment.
- `alloy_pull_request.yml`: validates the Alloy Jinja template, then deploys Alloy.
- `nginx_pull_request.yml`: validates `nginx/nginx.conf` using the production Nginx image, then deploys Nginx.

### Frontend validation gate

- `frontend_pull_request.yml`: Node.js 24 and pnpm 10 frozen install, ESLint, non-blocking Feature-Sliced Design lint, and application build, followed by the production image build and deployment.

## Component production delivery

Backend and Frontend production jobs run on the standard `pull_request` activity for pull requests targeting `master`. On `opened`, `synchronize`, and `reopened`, the applicable component validation job runs first; successful validation unlocks the image build when present, and a successful build unlocks deployment. The separate Taski-Exesh e2e workflow runs in parallel and does not gate either component deployment. Pushes to Backend or Frontend `master` do not run deployment workflows.

Backend workflows use component path filters, while the Frontend workflow runs for every pull request to its `master`. They deploy automatically after their declared validation/build dependencies succeed and do not reference a GitHub Environment approval gate. For pull requests, `github.sha` is the GitHub-generated pull-request merge revision; image builds and deployments use that same immutable revision tag.

Backend deploy jobs check out the pull-request revision, so Ansible and encrypted-variable changes from the pull request are used by the deployment. Frontend builds the pull-request image but checks out the deploy playbook from `github.event.pull_request.base.sha` before deploying that image.

Alloy, Analyzer, Duely, Nginx, and Frontend serialize deploy jobs with component-specific `production-*` concurrency groups and do not cancel an in-progress deployment. The current Taski and Exesh deploy jobs do not declare a concurrency group.

Task storage is the exception: `tasks_push.yml` in `CoDuels-Tasks` deploys on each push to its `master` branch. It does not build an image.

The production flows are:

- `Duely` -> build runtime and migration images, then run migration and deploy Duely.
- `Exesh` -> build Exesh and dashboard images, then deploy Coordinator, Workers, and Dashboard.
- Taski application -> build/deploy Taski from a Backend pull request; task storage -> deploy from a Tasks `master` push.
- `Analyzer` -> train models, build/push the image, then deploy it.
- `nginx` -> upload configuration and recreate Nginx.
- `alloy` -> render vault-protected configuration and recreate Grafana Alloy.
- Frontend pull request -> build/push and deploy Frontend.

The root repository does not participate in production delivery. Advancing its Backend or Frontend gitlink only changes the revisions recorded by the superproject.

## Ansible components

Build inventories use localhost and invoke Docker builds/pushes. Deployment playbooks target existing production inventory hosts and must run only from the owning repository workflow unless the user explicitly authorizes a manual deployment.

- Duely, Exesh, Taski, and Alloy require Vault credentials.
- Analyzer, Nginx, and task storage use password-authenticated Ansible without a Vault file.
- Frontend uses a temporary SSH private-key file and deploys as `ubuntu`.
- Backend services use the external Docker network `coduels`.

## GitHub configuration

Configure values in the repository that owns each workflow; repository-scoped secrets do not migrate automatically:

- Backend secrets: `DOCKER_PASSWORD`, `SSH_PASSWORD`, and `VAULT_PASSWORD`.
- Frontend secrets: `DOCKER_PASSWORD` and `SSH_PRIVATE_KEY`; Frontend variable: `VITE_BASE_URL`.
- Tasks secret: `SSH_PASSWORD`.
- Backend and Frontend branch protection should require the applicable pull-request checks. A same-repository pull request can receive Actions secrets and deploy; a fork pull request does not receive those secrets.
- Root branch protection can still require pull requests for submodule-pointer and documentation changes, but merging root changes does not trigger deployment.

Do not place credentials in workflow YAML, decrypt vault files in CI logs, or manually invoke a production playbook without explicit user authorization.
