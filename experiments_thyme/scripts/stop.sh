#!/usr/bin/env bash
# Remove the experiments_thyme container. Refuses to touch any container that
# launch.sh did not create (e.g. the team's mango-vllm baseline).
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-thyme-vllm}"

if ! docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "No container named '$CONTAINER_NAME'."
  exit 0
fi

label="$(docker container inspect --format '{{index .Config.Labels "greenmind.experiment"}}' "$CONTAINER_NAME")"
if [[ "$label" != "thyme" ]]; then
  echo "Refusing: '$CONTAINER_NAME' was not started by experiments_thyme/scripts/launch.sh." >&2
  exit 1
fi

docker rm -f "$CONTAINER_NAME"
