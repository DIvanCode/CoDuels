---
name: coduels-development
description: Implement and review CoDuels product features across Frontend, Duely, Taski, Exesh, Analyzer, filestorage, and Docs. Use for feature work, API or WebSocket contract changes, domain-model changes, cross-service debugging, repository orientation, and deciding which component owns a behavior. Use coduels-execution for scheduler/job/isolation details, coduels-anticheat for action/ML changes, and coduels-delivery for CI/Ansible/deployment work.
---

# Develop CoDuels

## Establish scope

1. Start from `/mnt/d/CoDuels` so the workspace-level instructions and all project skills are discovered.
2. Identify the owning repository: root `CoDuels` owns `Docs/`, release configuration, and submodule pointers; `Backend` and `Frontend` are submodules that own their application code. Check the applicable root or submodule status before editing.
3. Read [references/project-map.md](references/project-map.md) for the component map and current data flows.
4. Read [references/verification.md](references/verification.md) before choosing setup or validation commands.
5. Treat executable code, tests, compose files, Ansible, and workflows as newer than the thesis when they disagree.
6. After a component change is merged in its own repository, update that submodule pointer through a pull request in root `CoDuels`; that merge is the release decision.

## Route the change

- Put user/session/group/duel/tournament/submission policy in Duely domain or application code.
- Put browser state, presentation, and interaction in Frontend while preserving Feature-Sliced Design.
- Put task package rules, testing strategies, execution-DAG construction, and verdict calculation in Taski.
- Put scheduling, worker capacity, job runtimes, artifacts, and isolation in Exesh.
- Put action feature extraction and inference/training in Analyzer.
- Put reusable bucket storage and transfer behavior in filestorage.
- Put public routing in Nginx and observability collection in Alloy.

## Implement contract-first

1. Locate the authoritative producer type and all consumers before changing a payload.
2. Change the owning domain/usecase first; keep controllers and transport handlers thin.
3. Update HTTP DTOs, WebSocket event payloads, polling/Kafka messages, TypeScript types, and Pydantic schemas together when affected.
4. Preserve JSON naming already used by the contract. Do not silently rename public fields.
5. For persistence changes, update EF/PostgreSQL mappings and migrations or Go storage SQL in the same change.
6. Update focused documentation when behavior or architecture changes; do not rewrite the thesis unless requested.

## Preserve boundaries

- In Frontend, import through FSD public APIs and use the shared RTK Query slice. Keep the single authenticated WebSocket lifecycle in `features/duel-session`.
- In Duely, preserve domain/application/infrastructure dependency direction and the transactional outbox for guaranteed side effects.
- In Go services, preserve domain/usecase/adapter separation and propagate cancellation through contexts.
- Never execute user code directly on the host. Route it through Exesh and `isolate`.
- Do not edit upstream `isolate` or `testlib` submodules for ordinary CoDuels work.

## Verify and report

1. Run the smallest relevant checks from [references/verification.md](references/verification.md).
2. Expand to downstream components when a shared contract changed.
3. Report changed repositories separately and list any checks skipped because infrastructure or dependencies were unavailable.
4. Do not deploy, push images, or mutate production as part of feature verification.
