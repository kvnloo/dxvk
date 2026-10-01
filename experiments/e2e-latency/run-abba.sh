#!/usr/bin/env bash
set -euo pipefail

if (( $# < 4 )); then
  cat >&2 <<'EOF'
usage:
  run-abba.sh <A.conf> <B.conf> -- <workload command...>

Runs A / B / B / A. The workload must terminate on its own.
Use the same deterministic scene and duration for every run.
EOF
  exit 2
fi

a="$1"
b="$2"
shift 2

if [[ "$1" != "--" ]]; then
  echo "expected -- before workload command" >&2
  exit 2
fi
shift

if (( $# == 0 )); then
  echo "missing workload command" >&2
  exit 2
fi

root="${LATENCY_RESULTS_DIR:-dxvk-latency-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$root"

./experiments/e2e-latency/capture-env.sh "$root/environment.txt"

run_one() {
  local label="$1"
  local config="$2"
  local index="$3"
  local dir="$root/${index}-${label}"
  mkdir -p "$dir"

  cp "$config" "$dir/dxvk.conf"
  {
    echo "label=$label"
    echo "config=$config"
    echo "started_at=$(date --iso-8601=ns)"
    printf 'command='
    printf '%q ' "$@"
    echo
  } > "$dir/run.txt"

  set +e
  DXVK_CONFIG_FILE="$PWD/$dir/dxvk.conf" \
  DXVK_LOG_PATH="$PWD/$dir" \
  DXVK_HUD="${DXVK_HUD:-latency}" \
    "${@:4}"
  status=$?
  set -e

  {
    echo "ended_at=$(date --iso-8601=ns)"
    echo "exit_status=$status"
  } >> "$dir/run.txt"

  return "$status"
}

run_one A "$a" 1 "$@"
run_one B "$b" 2 "$@"
run_one B "$b" 3 "$@"
run_one A "$a" 4 "$@"

echo "results: $root"
