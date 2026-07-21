# CoDuels superproject guide

## Workspace shape

- This directory is the primary `CoDuels` Git repository. It owns `Docs/`, shared agent instructions, and the exact backend/frontend revisions tracked together. It does not own production workflows.
- `Backend/` and `Frontend/` are Git submodules. Develop, validate, and deploy application changes through pull requests in their own repositories, then advance the affected submodule pointer here when the superproject should track the new revision.
- Run root Git commands for documentation, shared agent instructions, and submodule-pointer changes. Run Git commands inside a submodule only for changes owned by that component repository.
- `Backend/filestorage` and `Backend/Taski/tasks` are project-owned submodules. `Backend/Exesh/isolate` and `Backend/Exesh/testlib` are upstream submodules. Do not accidentally include submodule changes in the parent repository.

## Release ownership

- The root `CoDuels` repository has no GitHub Actions workflows and advancing a root submodule pointer does not deploy anything.
- Backend production delivery belongs to the path-filtered `duely_pull_request.yml`, `analyzer_pull_request.yml`, `alloy_pull_request.yml`, `nginx_pull_request.yml`, `taski_pull_request.yml`, and `exesh_pull_request.yml` workflows in `CoDuels-Backend`. Each component workflow validates its own component, then builds when applicable and deploys the pull-request revision. `e2e_tests_pull_request.yml` runs the Taski-Exesh scenario independently for Taski or Exesh changes; it is not a dependency of their build or deploy jobs.
- Frontend production delivery belongs to `frontend_pull_request.yml` in `CoDuels-Frontend`. It validates and builds the pull-request revision, then deploys that image with the deploy playbook checked out from the trusted base revision.
- Backend and Frontend pull-request deployments run automatically without a GitHub Environment approval. Pushes to either component repository's `master` branch do not deploy.
- Task storage production delivery belongs to `tasks_push.yml` in `CoDuels-Tasks` and runs on pushes to its `master` branch.
- Keep the required production secrets and variables in the repository that owns each workflow. Same-repository pull requests can use them; pull requests from forks do not receive Actions secrets.

## GitHub issue workflow

- When the user sends only a GitHub issue link, treat it as a request to complete the following workflow unless they explicitly ask for analysis only:
  1. Move the issue's project item to **In Progress** before starting implementation.
  2. Implement and verify the issue in a separate branch, push it, and open a Draft Pull Request.
  3. Link the issue to the Pull Request with a closing reference and move the project item to **Review** after the Draft Pull Request is created.
- Preserve unrelated local work. If the current checkout is dirty or belongs to another task, use an isolated worktree for the issue branch.
- When the user says they left Pull Request comments or asks to check them, immediately implement every unambiguous unresolved actionable thread. Ask for direction only when comments conflict, are ambiguous, or require a material product or architecture choice.

## Source of truth

- Use current code, tests, Docker/Ansible configuration, and workflows as the executable source of truth.
- Use `Docs/thesis/items/` for system intent and algorithms, then verify every operational detail against code. The thesis describes the original Kafka-centric flow; current production configuration uses REST polling for Taski/Exesh status propagation while local configuration still uses Kafka in places.
- Keep public API payloads, WebSocket events, Go/C# domain types, Frontend TypeScript types, and Analyzer Pydantic schemas synchronized.

## System map

- `Frontend/`: React 19, TypeScript, Redux Toolkit/RTK Query, Vite, Feature-Sliced Design, Monaco Editor.
- `Backend/Duely/`: ASP.NET Core on .NET 8. Owns users, JWT/refresh tokens, groups, duel configurations, matchmaking, duels, tournaments, submissions, WebSockets, user actions, EF Core/PostgreSQL, and the transactional outbox.
- `Backend/Taski/`: Go 1.24. Owns task packages/files, Polygon import, test-plan creation, verdict calculation, and testing status messages.
- `Backend/Exesh/`: Go 1.24. Coordinator schedules execution DAGs; workers execute jobs and exchange artifacts. Untrusted runs use Linux `isolate` inside privileged worker containers.
- `Backend/Analyzer/`: Python/FastAPI/scikit-learn. Converts duel actions to an ordered feature vector and returns a suspicion score.
- `Backend/filestorage/`: Go submodule for SHA-1-addressed bucket storage and tar-stream transfer.
- `Backend/nginx/`: reverse proxy for Duely, Taski task files, WebSocket upgrades, and the Exesh dashboard.
- `Backend/alloy/`: Grafana Alloy configuration for Prometheus remote write and Docker log shipping.
- `Docs/`: Russian Markdown and LaTeX sources, architecture diagrams, slides, and thesis.

## Working rules

- Use the project skills when relevant: `$coduels-development`, `$coduels-execution`, `$coduels-anticheat`, and `$coduels-delivery`.
- Start cross-service changes at the owning domain, then update transport contracts and consumers. Do not put business rules in Frontend components or HTTP handlers.
- Use Conventional Commits (`type(scope): description`) for every commit and use the same concise, imperative convention for pull-request titles.
- Preserve the existing architecture: FSD boundaries in Frontend; application/domain/infrastructure direction in Duely; domain/usecase/adapter separation in Go services.
- Never run user-supplied code directly on the host. Keep execution through Exesh workers and `isolate`.
- For every Taski or Exesh change, run `Backend/e2e/taski-exesh/run.sh` after focused tests. Review and update that scenario when related service contracts, Docker/Compose/Ansible configuration, task fixtures, submodules, infrastructure, or configs change.
- When adding a cross-service Backend e2e scenario, follow `Backend/e2e/README.md` and add a pull-request workflow whose paths cover all participating services, the scenario, and related configuration/infrastructure without duplicate runs.
- Never decrypt, print, or replace `ansible/deploy/credentials.yml` unless the user explicitly requests credential maintenance. Never deploy, push images, or run production playbooks without explicit authorization.
- A push to an open same-repository Backend or Frontend pull request starts applicable automatic production workflows. Treat that push as a production action and perform it only when the user explicitly authorizes the push and its deployment effect.
- Prefer focused verification. If dependencies or infrastructure are unavailable, report exactly which checks were not run.

## Verification entry points

- Frontend: from `Frontend/`, run `pnpm install --frozen-lockfile` when needed, then `pnpm lint`, `pnpm fsd:lint`, and `pnpm build`.
- Duely: from `Backend/Duely/`, run `dotnet test --configuration Release`.
- Exesh: from `Backend/Exesh/`, run `go test ./...`.
- Taski: from `Backend/Taski/`, run `go test ./...`.
- Taski-Exesh e2e: after any Taski or Exesh change, run `Backend/e2e/taski-exesh/run.sh` from the root repository.
- filestorage: from `Backend/filestorage/`, run `go test ./...`.
- Analyzer: use a Python 3.10 virtual environment, install `requirements.txt`, and run `python train.py --data-dir data/train` only when training/features change. Model artifacts are required before starting the API.
- Docs: from `Docs/thesis/` or `Docs/slides/`, run `make` when LaTeX output is affected; this needs `latexmk`, a suitable TeX installation, Pygments, and shell escape.

## Local environment

- Initialize backend submodules with `git -C Backend submodule update --init --recursive` after cloning.
- The Docker stack assumes the external network named `coduels`. Start `Backend/docker-compose.yml` before component compose files.
- `Backend/up.sh` does not start Analyzer. Train Analyzer models and start `Backend/Analyzer/docker-compose.yml` separately when testing the full anti-cheat path.
- Frontend requires `VITE_BASE_URL`, normally `http://localhost/api` when using the local Nginx proxy.
