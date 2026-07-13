# Verification and local setup

## Required toolchain

- Docker Engine/Desktop with Compose v2 and Linux/WSL integration.
- Frontend: Node.js 24 and pnpm 10.
- Duely: .NET SDK 8.
- Go services: Go 1.24.
- Analyzer: Python 3.10 and a virtual environment.
- Backend checkout: initialized recursive Git submodules.
- Optional delivery work: Ansible and the Docker Python package.
- Optional docs work: `latexmk`, TeX packages used by `spbudiploma.sty`, Pygments for `minted`, and shell escape.

## Bootstrap

```bash
git -C Backend submodule update --init --recursive

cd Frontend
pnpm install --frozen-lockfile

cd ../Backend/Analyzer
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt
```

Do not install dependencies automatically when the user only asked for analysis/review. Ask before adding or upgrading project dependencies.

## Component checks

Frontend:

```bash
cd Frontend
pnpm lint
pnpm fsd:lint
pnpm build
```

Duely, matching PR CI:

```bash
cd Backend/Duely
dotnet test --configuration Release
```

Go services:

```bash
cd Backend/Exesh && go test ./...
cd Backend/Taski && go test ./...
cd Backend/filestorage && go test ./...
```

Run `gofmt -w` only on changed Go files before tests.

Analyzer:

```bash
cd Backend/Analyzer
. .venv/bin/activate
python train.py --data-dir data/train
uvicorn app:app --host 127.0.0.1 --port 8000
```

Training is necessary when feature names/order, extraction, trainers, or datasets change. The API cannot start without at least one expected artifact.

Docs:

```bash
make -C Docs/thesis
make -C Docs/slides
```

## Local stack notes

`Backend/docker-compose.yml` creates the external Docker network `coduels` plus Kafka/Zookeeper/Nginx. Component compose files expect that network to exist.

`Backend/up.sh` starts root infrastructure, Exesh, Taski, and Duely, but not Analyzer. For the full path:

1. Train Analyzer models.
2. Start root Backend compose.
3. Start Exesh, Taski, Analyzer, and Duely compose projects.
4. Start Frontend with `VITE_BASE_URL=http://localhost/api`, or build its container separately.

Workers are privileged because `isolate` needs Linux namespaces/cgroups. Do not weaken isolation or run arbitrary solutions on the host as a shortcut.

## Validation scope

- UI-only change: Frontend lint, FSD lint, build.
- Duely domain/API change: Duely tests; Frontend build if contract-facing.
- Task/test strategy change: Taski tests; Exesh tests if graph/job contracts change.
- Scheduler/runtime change: Exesh tests; Taski tests for contract changes; filestorage tests for artifact behavior.
- Anti-cheat contract/feature change: Frontend checks, Duely tests, Analyzer training/smoke checks.
- CI/Ansible change: syntax/lint in check mode where safe; never execute production deployment during verification.
