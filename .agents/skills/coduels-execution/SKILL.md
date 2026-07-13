---
name: coduels-execution
description: Change or debug CoDuels automatic judging and distributed execution across Taski, Exesh Coordinator/Workers, filestorage, task packages, job DAGs, verdicts, scheduling, resource accounting, runtimes, and Linux isolate. Use for new task formats or languages, test strategies, job/message contracts, scheduler behavior, worker failures, artifacts, performance, and sandboxing.
---

# Maintain distributed execution

## Load the execution model

Read [references/execution-map.md](references/execution-map.md) before changing Taski, Exesh, task packages, filestorage, or execution contracts. Use the current code as authority for job/status fields and configuration.

## Select the owner

- Change Taski for task metadata, Polygon conversion, test strategies, DAG construction, testing progress, and verdict rules.
- Change Exesh for Execution persistence, job readiness, priority, promises/reservations, worker capacity, runtimes, messages, and retry behavior.
- Change filestorage for reusable bucket lifecycle or transfer semantics.
- Change `Taski/tasks` for task content, not application behavior.
- Change Duely/Frontend only when their testing or code-run contracts and status displays must follow.

## Preserve execution invariants

1. Keep Execution and stage/job dependencies acyclic and ensure every artifact input is produced by an earlier dependency or declared source.
2. Keep compile/run/check responsibilities explicit. Add a language by updating Taski preparation/run construction and Exesh job/domain/runtime/executor registration together.
3. Keep verdict authority in Taski. Exesh reports job outcomes and resources; it must not invent product verdicts.
4. Preserve terminal-state monotonicity: late progress messages must not overwrite a completed verdict.
5. Preserve idempotent message polling/outbox semantics and ordered message IDs when changing Kafka/REST adapters.
6. Keep worker slot and memory accounting consistent with scheduler reservations and completions.
7. Never replace `isolate` with direct host execution for convenience.

## Work safely

- Do not modify upstream `Exesh/isolate` or `Exesh/testlib` unless the task explicitly requires an upstream fork change.
- Treat privileged worker containers and Docker socket access as security-sensitive.
- Do not run arbitrary or user-provided solutions outside the existing worker sandbox.
- Avoid load tests by default; they consume substantial local resources. Use deterministic unit tests first.

## Verify

1. Run `go test ./...` in each changed Go module: Exesh, Taski, and/or filestorage.
2. Run `gofmt` on changed Go files.
3. If a contract changed, run tests in both producer and consumer and verify Duely gateways/pollers.
4. Use compose only when an integration result is necessary. Start the root Backend compose first so the external `coduels` network exists.
5. Report whether isolation was exercised; unit tests alone do not prove the host kernel/cgroup setup.
