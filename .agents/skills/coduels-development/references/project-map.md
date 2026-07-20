# CoDuels project map

## Contents

- [Repository topology](#repository-topology)
- [Product intent](#product-intent)
- [Component ownership](#component-ownership)
- [Main flows](#main-flows)
- [Documentation versus runtime](#documentation-versus-runtime)

## Repository topology

`/mnt/d/CoDuels` is the primary `CoDuels` Git repository and release superproject.

- `Docs/` and the component-specific production release workflows are tracked directly by `CoDuels`.
- `Backend/` -> `DIvanCode/CoDuels-Backend` submodule.
- `Frontend/` -> `DIvanCode/CoDuels-Frontend` submodule.

Application changes are reviewed and validated in the component repositories. A root pull request advances one or both submodule revisions; merging it is the only production-release trigger.

Backend submodules:

- `filestorage/` -> project-owned Go library.
- `Taski/tasks/` -> project-owned task storage, released through the root `CoDuels` workflow when its nested submodule revision changes.
- `Exesh/isolate/` -> upstream sandbox utility.
- `Exesh/testlib/` -> upstream checker library.

## Product intent

CoDuels is a sports-programming platform centered on two-person duels. It supports rating-based and friendly duels, configurable multi-task duels, groups, group duels, tournaments, history/upsolving, live code visibility when enabled, automatic judging, and post-duel behavior analysis.

Supported solution languages in the current testing design are C++, Python, and Go. A task contains statement files, tests, limits, solution/checker artifacts, topics, and a level from 1 to 10.

## Component ownership

### Frontend

- React 19 + TypeScript + Redux Toolkit/RTK Query + redux-persist + Vite.
- Feature-Sliced Design layers: `app`, `pages`, `widgets`, `features`, `entities`, `shared`.
- Monaco Editor provides code editing and action tracking.
- `VITE_BASE_URL` selects the API root; normal local value is `http://localhost/api`.
- HTTP calls share `src/shared/api/api.ts`; access-token refresh is mutex-protected.
- The authenticated WebSocket is owned by `features/duel-session/api/duelSessionApi.ts` and uses a one-time ticket from Duely.

### Duely

- ASP.NET Core/.NET 8 with 18 source projects plus test projects.
- Owns users, JWT access/refresh tokens, groups/roles/invitations, duel configurations, matchmaking, duels, tournaments, submissions, code runs, WebSockets, and collected user actions.
- Uses EF Core/PostgreSQL and a transactional outbox/background jobs.
- Browser-facing routes are in `Duely.Infrastructure.Api.Http/Controllers`.
- Gateways call Taski, Exesh, and Analyzer.
- Taski and Exesh status updates can use Kafka consumers or REST pollers, selected independently by configuration.

### Taski

- Go 1.24 service using Chi, pgx, Prometheus, Kafka/REST adapters, and filestorage.
- Owns task retrieval/files/topics/random selection, Polygon upload, testing strategies, execution graph construction, solution state, and verdict calculation.
- Main endpoints include `/task/{id}`, `/task/{id}/*`, `/task/list`, `/task/random`, `/task/topics`, `/test`, and `/solutions/{id}/messages`.
- Task files are mounted from `Taski/tasks/storage` locally and deployed by the root release workflow after the nested submodule revision is promoted through Backend and then CoDuels.

### Exesh

- Go 1.24 with Coordinator and Worker binaries.
- Coordinator persists Executions, schedules ready Jobs, tracks workers/resources, stores messages/outbox data, and exposes `/execute`, `/heartbeat`, and `/executions/{id}/messages`.
- Workers heartbeat for work, fetch source artifacts, execute jobs, and publish output artifacts.
- Job types: `compile_cpp`, `compile_go`, `run_cpp`, `run_py`, `run_go`, `check_cpp`, and `chain`.
- Compile jobs use a local runtime inside the worker container; run/check jobs use Linux `isolate`.
- Prometheus endpoints are separate from service HTTP endpoints.

### Analyzer

- Python 3.10, FastAPI, pandas, scikit-learn.
- `/predict` accepts ordered user actions plus `user_rating` and returns `score` in `[0,1]`.
- `/health` reports the loaded model role and path.
- Startup loads the production random forest first and the baseline logistic regression as fallback. A model artifact must exist.
- Training data lives under `data/train/{normal,cheater}`. `train.py` writes ignored artifacts under `artifacts/`.

### filestorage

- Go 1.24 library used by Taski and Exesh.
- A bucket is addressed by a 20-byte SHA-1 value represented as 40 hex characters and sharded by the first byte.
- Supports permanent/TTL buckets, cleanup, complete-bucket or single-file download, compressed tar-stream transfer, and commit/abort semantics.

### Edge and observability

- Backend Nginx proxies `/api/users`, `/api/groups`, `/api/tournaments`, `/api/duels`, `/api/code-runs`, and `/api/actions` to Duely; `/api/task` to Taski; `/exesh-dashboard/` to the Django dashboard; and upgrades `/api/users/connect` to WebSocket.
- Grafana Alloy scrapes Duely, Taski, Coordinator, and Workers and ships metrics/logs to Grafana Cloud.

## Main flows

### Submit a solution

1. Frontend posts a submission to Duely.
2. Duely asks Taski to test it.
3. Taski converts the task/language/checker requirements into an Execution DAG and posts it to Exesh.
4. Exesh schedules Jobs across Workers; Workers exchange artifacts through filestorage and run untrusted code through `isolate`.
5. Taski consumes/polls Exesh messages, derives progress/verdict, and emits/stores testing messages.
6. Duely consumes/polls Taski messages and pushes submission updates through WebSocket.
7. Frontend merges the event into RTK Query caches without regressing a terminal `Done` status.

### Run code on custom/sample input

Frontend -> Duely -> Exesh. Taski is bypassed because no task-wide verdict is needed. Duely receives/polls execution messages and pushes progress/result through WebSocket.

### Live duel state

Frontend obtains a one-time connection ticket from Duely, opens `/users/connect`, receives duel/invitation/submission events, and optionally sends `SolutionUpdated` once per second when opponent-code visibility is enabled.

### Anti-cheat

Frontend batches editor/system actions -> Duely persists them -> a post-duel background process sends actions plus rating to Analyzer -> Analyzer returns a suspicion score.

## Documentation versus runtime

The thesis and `Docs/tech.md` describe Kafka as the primary asynchronous backbone. Current code supports both Kafka and REST message polling. Current production files select REST for the Taski and Exesh paths:

- Duely `appsettings.Production.json`: Taski and Exesh status mode `rest`.
- Exesh deploy playbook: `DISPATCHER_KAFKA_ENABLED=false`.
- Taski deploy playbook: `EVENT_CONSUMER_MODE=rest` and `MESSAGE_DISPATCHER_KAFKA_ENABLED=false`.

Local compose/config still enables Kafka for some paths. Always verify the target environment before changing transport behavior.
