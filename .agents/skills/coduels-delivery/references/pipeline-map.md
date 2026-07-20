# CoDuels delivery map

## Contents

- [Repository model](#repository-model)
- [Component validation](#component-validation)
- [Root production release](#root-production-release)
- [Ansible components](#ansible-components)
- [GitHub configuration](#github-configuration)

## Repository model

- Root `CoDuels` owns `Docs/`, the component-specific `.github/workflows/release-*.yml` files, reusable release workflows, root secrets/variables, and the Backend/Frontend submodule revisions that define a release.
- `Backend` and `Frontend` are submodules with independent pull-request CI. They must not contain production deployment workflows.
- `Backend/Taski/tasks` is itself a project-owned submodule. Its task-storage deployment is performed only when its revision is included in a promoted Backend revision and then in a merged root CoDuels pull request.
- `Backend/filestorage` has its own pull-request Go test workflow and no production deployment workflow.

## Component validation

### Backend

- `duely_pull_request.yml`: .NET 8 Release tests and PR coverage report for `Duely/**`.
- `exesh_pull_request.yml`: Go 1.24 tests plus Django dashboard system check for `Exesh/**`.
- `taski_pull_request.yml`: Go 1.24 tests for Taski application changes, excluding the nested tasks submodule.
- `taski_exesh_e2e_pull_request.yml`: isolated Docker Compose Taski-Exesh A+B acceptance flow for Taski, Exesh, the scenario itself, and related root Compose/submodule configuration. It checks out recursive submodules and runs the same `e2e/taski-exesh/run.sh` entry point used locally.
- `analyzer_pull_request.yml`: Python 3.10 dependency install, syntax compilation, and baseline/production model training for `Analyzer/**`.
- `nginx_pull_request.yml`: validates `nginx/nginx.conf` using the production Nginx image.

### Frontend

- `frontend_pull_request.yml`: Node.js 24 and pnpm 10 frozen install, ESLint, Feature-Sliced Design lint, and production build.

## Root production release

Each component has a separate `release-<component>.yml` workflow. The workflows start only after a pull request into `master` that changes their root submodule is closed, and they continue only when the pull request was merged. Every deployment checks out the exact merge commit rather than the moving branch tip and targets the `production` GitHub Environment. With a required reviewer configured, every affected component waits for **Review deployments → Approve and deploy** and does not contact production before that approval.

Frontend releases are selected directly by the root `Frontend` gitlink change. Backend workflows share `check-backend-component.yml`, which compares the Backend gitlinks from the pull request base and merge revisions and reports whether that workflow's explicit component path changed. The reusable `release-component.yml` contains the common checkout, Ansible setup, image build, authentication, deployment, and credential-cleanup steps. There is no dynamic matrix or generated component list.

The component workflows are:

- `Duely` -> build runtime and migration images, then run migration and deploy Duely.
- `Exesh` -> build Exesh and dashboard images, then deploy Coordinator, Workers, and Dashboard.
- Taski application -> build/deploy Taski; a `Taski/tasks` gitlink change separately deploys task storage.
- `Analyzer` -> train models, build/push the image, then deploy it.
- `nginx` -> upload configuration and recreate Nginx.
- `alloy` -> render vault-protected configuration and recreate Grafana Alloy.
- Frontend submodule change -> build/push and deploy Frontend.

Each image build uses the immutable root merge SHA as its tag. Releases are serialized per component with a `production-<component>` concurrency group, so a newer release of the same component waits for the running one while unrelated components can proceed independently.

## Ansible components

Build inventories use localhost and invoke Docker builds/pushes. Deployment playbooks target existing production inventory hosts and must only run in the root release workflow.

- Duely, Exesh, Taski, and Alloy require Vault credentials.
- Analyzer, Nginx, and task storage use password-authenticated Ansible without a Vault file.
- Frontend uses a temporary SSH private-key file and deploys as `ubuntu`.
- Backend services use the external Docker network `coduels`.

## GitHub configuration

After the GitHub repository rename, configure these values on root `CoDuels`; repository-scoped secrets from Backend and Frontend do not migrate automatically:

- Secrets: `DOCKER_PASSWORD`, `SSH_PASSWORD`, `VAULT_PASSWORD`, and `SSH_PRIVATE_KEY`.
- Variable: `VITE_BASE_URL`.
- Environment: create `production` and configure yourself as a required reviewer. This is required: it turns the release job into a manual approval step rather than an automatic deployment.
- Root branch protection: require pull requests before merging into `master` and block direct pushes. Deployment remains paused for manual environment approval, so temporary production outages do not block merges.
- Component branch protection: require Backend's applicable PR workflow and Frontend's `Frontend` workflow before merging their `master` branches. This makes the submodule revision promoted through root CoDuels a previously validated revision.

Do not place credentials in workflow YAML, decrypt vault files in CI logs, or manually invoke a production playbook outside an approved release.
