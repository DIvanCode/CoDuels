#!/usr/bin/env bash
set -euo pipefail

set -a && source .env && set +a

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "usage: $0 <polygon_packages_dir> <level 1..10>" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

PACKAGES_PATH="$1"
LEVEL="$2"

if [[ ! -d "$PACKAGES_PATH" ]]; then
  echo "packages path does not exist: $PACKAGES_PATH" >&2
  exit 1
fi

if ! [[ "$LEVEL" =~ ^[0-9]+$ ]] || (( LEVEL < 1 || LEVEL > 10 )); then
  echo "level must be an integer in range [1..10], got: $LEVEL" >&2
  exit 1
fi

for file in $PACKAGES_PATH/*; do
    if [[ -f "$file" && "$file" == *.zip ]]; then
        bash $SCRIPT_DIR/upload-task.sh "$file" $LEVEL
    fi
done