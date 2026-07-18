# CoDuels superproject guide

## Workspace shape

- This directory is the primary `CoDuels` Git repository. It owns `Docs/`, release workflows, shared agent instructions, and the exact backend/frontend revisions released together.
- `Backend/` and `Frontend/` are Git submodules. Develop and commit application changes in their own repositories, then open a `CoDuels` pull request that advances the affected submodule pointer.
- Run root Git commands for documentation, release configuration, and submodule-pointer changes. Run Git commands inside a submodule only for changes owned by that component repository.
- `Backend/filestorage` and `Backend/Taski/tasks` are project-owned submodules. `Backend/Exesh/isolate` and `Backend/Exesh/testlib` are upstream submodules. Do not accidentally include submodule changes in the parent repository.

## Release ownership

- Production delivery belongs only to this repository's `.github/workflows/release-production.yml`.
- A merge into `master` creates the release workflow but never starts deployment by itself. Configure the `production` GitHub Environment with yourself as a required reviewer; the release job will wait until you click **Review deployments → Approve and deploy**. It compares the merged PR's submodule revisions and deploys only affected Frontend or Backend service components.
- Do not add push-to-production workflows to `CoDuels-Backend`, `CoDuels-Frontend`, or project-owned nested submodules. Their workflows perform pull-request validation only.
- The `production` GitHub Environment and the release secrets/variable must be configured in this repository after the GitHub rename. Direct pushes to `master` should be blocked by branch protection in root and component repositories, with their respective PR checks required before merge.

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
