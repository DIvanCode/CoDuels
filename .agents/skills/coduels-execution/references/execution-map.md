# Execution and judging map

## Contents

- [Responsibilities](#responsibilities)
- [Taski model](#taski-model)
- [Exesh model](#exesh-model)
- [Scheduling](#scheduling)
- [Sources and artifacts](#sources-and-artifacts)
- [Isolation boundary](#isolation-boundary)
- [Status transport](#status-transport)
- [Verification](#verification)

## Responsibilities

Taski translates a task and a submitted solution into a testing strategy and an Exesh Execution. Exesh executes the graph. Taski consumes Exesh messages and converts job outcomes into user-facing testing status and verdicts.

For a custom/sample code run, Duely can construct/request Exesh work directly without Taski because no task-wide verdict is needed.

## Taski model

Taski currently supports three task strategy families:

- `WriteCode`: compile/prepare the submitted program if needed, run it on tests, and invoke the checker. Tests are grouped into dependency stages of five.
- `PredictOutput`: check a submitted output against the expected output with the task checker.
- `FindTest`: run source/reference programs on a submitted test and compare results through the checker.

Taski owns:

- task metadata and file paths;
- allowed languages and preparation/run job selection;
- stages, job dependencies, sources, and expected success statuses;
- solution persistence and testing messages;
- mapping job status to Accepted, Wrong Answer, Runtime Error, Time Limit, Memory Limit, or testing failure;
- selecting the earliest failed test only after the required preceding test results are known.

Key locations:

- `Taski/internal/domain/task/`
- `Taski/internal/domain/testing/strategy/`
- `Taski/internal/domain/testing/execution/`
- `Taski/internal/api/testing/`
- `Taski/internal/handler/` and `internal/consumer/`
- `Taski/internal/storage/`
- `Taski/cmd/uploader/` for Polygon packages.

## Exesh model

An Execution is a DAG of Jobs plus named sources. Coordinator persists and schedules it. Workers request work using heartbeat, download sources/artifacts, execute, save outputs, and return results.

Job types:

- `compile_cpp`
- `compile_go`
- `run_cpp`
- `run_py`
- `run_go`
- `check_cpp`
- `chain`

Compile jobs use the local runtime inside the worker container. Run and checker jobs use the isolate runtime. `chain` executes a composed sequence through registered runtimes.

Key locations:

- `Exesh/internal/domain/execution/`
- `Exesh/internal/factory/`
- `Exesh/internal/scheduler/`
- `Exesh/internal/worker/`
- `Exesh/internal/executor/`
- `Exesh/internal/runtime/{local,isolate}/`
- `Exesh/internal/provider/` for sources/outputs.
- `Exesh/internal/storage/postgres/`
- `Exesh/internal/api/{execute,heartbeat,messages}/`

## Scheduling

The current Execution priority implementation uses:

```text
gamma^(tries-1) * (alpha * expected_remaining_ratio + elapsed_ms / total_expected_ms)
```

with `alpha = 10.3174` and `gamma = 1.31` in code. Verify constants and formula in `internal/scheduler/execution.go` before changing or documenting them.

The Job scheduler:

1. Considers existing promised jobs first.
2. Starts a promised job when it fits the requesting worker without violating reservations.
3. Otherwise scans one ready job per prioritized Execution.
4. Starts the first job that fits now.
5. May reserve a future start on the best worker up to `promised_jobs_limit`.
6. Periodically reschedules promises when better placement is possible without delaying existing promises.

Worker capacity has two constraints:

- available slots, based on the number of running jobs;
- available memory, based on the sum of expected memory for running/reserved jobs.

Any completion, retry, worker death, or promise change must release/update both views exactly once.

## Sources and artifacts

Task package files, inline submitted code/input, and prior Job outputs become named inputs. An artifact input must name a producing Job. Exesh source/output providers use filestorage and TTLs to avoid permanent growth.

filestorage behavior:

- bucket ID is a 20-byte SHA-1 value (40 hex characters);
- buckets may be permanent or expire;
- complete buckets and individual files can be fetched;
- transfers use compressed tar streams;
- downloads stage into temporary storage and require commit/abort;
- an existing local bucket/file is not downloaded again.

## Isolation boundary

Workers are privileged containers because isolate uses Linux namespaces, cgroups, capabilities, and syscall controls. Run/check jobs must restrict filesystem access, network, processes/threads, CPU time, memory, and dangerous syscalls. Resource-limit measurements must stay compatible with contest verdict semantics.

Do not test untrusted samples on the host. A local runtime is acceptable only for trusted compilation steps already modeled that way.

## Status transport

The original architecture uses Kafka topics `exesh.step-updates` and `taski.testing`. Current services also expose ordered REST message polling:

- Exesh: `/executions/{execution_id}/messages`
- Taski: `/solutions/{solution_id}/messages`

Transport is configuration-dependent. Production playbooks currently disable Exesh/Taski Kafka dispatch and use REST polling; local configuration still enables Kafka in places. Preserve parity between transport implementations.

## Verification

- Exesh: `go test ./...`
- Taski: `go test ./...`
- filestorage: `go test ./...`
- Contract change: test both modules and inspect Duely gateway/status polling code.
- Runtime/isolate change: build the Exesh container and exercise only trusted fixtures in the privileged worker environment.
- Performance/scheduler change: add deterministic scheduler tests before running load experiments.
