#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "usage: $0 <polygon-package.zip> <level 1..10>" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

ARCHIVE_PATH="$1"
LEVEL="$2"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  echo "task archive does not exist: $ARCHIVE_PATH" >&2
  exit 1
fi

if [[ "${ARCHIVE_PATH,,}" != *.zip ]]; then
  echo "task archive must be a .zip Polygon package: $ARCHIVE_PATH" >&2
  exit 1
fi

if ! [[ "$LEVEL" =~ ^[0-9]+$ ]] || (( LEVEL < 1 || LEVEL > 10 )); then
  echo "level must be an integer in range [1..10], got: $LEVEL" >&2
  exit 1
fi

for command in docker realpath flock; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "required command is not installed: $command" >&2
    exit 1
  fi
done

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose plugin is not available" >&2
  exit 1
fi

ARCHIVE_PATH="$(realpath "$ARCHIVE_PATH")"
TASKS_DIR="$SCRIPT_DIR/tasks"
mkdir -p "$TASKS_DIR/storage"

if [[ ! -w "$TASKS_DIR" ]]; then
  echo "task storage is not writable: $TASKS_DIR" >&2
  exit 1
fi

exec 9>"$TASKS_DIR/.upload.lock"
if ! flock -n 9; then
  echo "another task upload is already running" >&2
  exit 1
fi

docker compose \
  --project-directory "$SCRIPT_DIR" \
  -f "$SCRIPT_DIR/docker-compose.yml" \
  run --rm --no-deps \
  --user "$(id -u):$(id -g)" \
  --volume "$ARCHIVE_PATH:/input/task.zip:ro" \
  task-uploader \
  -format polygon \
  -src /input/task.zip \
  -level "$LEVEL"
