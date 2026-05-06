#!/usr/bin/env bash
# examples-auto-run/scripts/run.sh
# Automatically discovers and runs all examples in the repository,
# capturing output and reporting pass/fail status.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
EXAMPLES_DIR="${REPO_ROOT}/examples"
LOG_DIR="${REPO_ROOT}/.agents/skills/examples-auto-run/logs"
TIMEOUT_SECONDS=${TIMEOUT_SECONDS:-60}
PYTHON_BIN=${PYTHON_BIN:-python}
PASSED=0
FAILED=0
SKIPPED=0
FAILED_EXAMPLES=()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "[examples-auto-run] $*"; }
warn() { echo "[examples-auto-run] WARN: $*" >&2; }
err()  { echo "[examples-auto-run] ERROR: $*" >&2; }

require_command() {
  if ! command -v "$1" &>/dev/null; then
    err "Required command not found: $1"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
require_command "$PYTHON_BIN"
require_command "timeout"

if [[ ! -d "$EXAMPLES_DIR" ]]; then
  err "Examples directory not found: $EXAMPLES_DIR"
  exit 1
fi

mkdir -p "$LOG_DIR"

# ---------------------------------------------------------------------------
# Discover examples
# ---------------------------------------------------------------------------
# Collect all top-level Python files and subdirectory entry points.
mapfile -t EXAMPLE_FILES < <(
  find "$EXAMPLES_DIR" -maxdepth 2 -name '*.py' \
    ! -name '__init__.py' \
    ! -name 'conftest.py' \
    | sort
)

if [[ ${#EXAMPLE_FILES[@]} -eq 0 ]]; then
  warn "No example files discovered under $EXAMPLES_DIR"
  exit 0
fi

log "Discovered ${#EXAMPLE_FILES[@]} example file(s)."

# ---------------------------------------------------------------------------
# Check for skip markers
# ---------------------------------------------------------------------------
should_skip() {
  local file="$1"
  # Files containing '# agents-skip' anywhere are excluded from auto-run.
  grep -qE '^\s*#\s*agents-skip' "$file"
}

# ---------------------------------------------------------------------------
# Run examples
# ---------------------------------------------------------------------------
for example in "${EXAMPLE_FILES[@]}"; do
  relative="${example#"$REPO_ROOT/"}"
  log_file="${LOG_DIR}/$(echo "$relative" | tr '/' '_').log"

  if should_skip "$example"; then
    log "SKIP  $relative"
    (( SKIPPED++ )) || true
    continue
  fi

  log "RUN   $relative"
  set +e
  timeout "$TIMEOUT_SECONDS" "$PYTHON_BIN" "$example" \
    > "$log_file" 2>&1
  exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    log "PASS  $relative"
    (( PASSED++ )) || true
  elif [[ $exit_code -eq 124 ]]; then
    warn "TIMEOUT $relative (>${TIMEOUT_SECONDS}s) — treating as failure"
    echo "[TIMEOUT after ${TIMEOUT_SECONDS}s]" >> "$log_file"
    FAILED_EXAMPLES+=("$relative (timeout)")
    (( FAILED++ )) || true
  else
    warn "FAIL  $relative (exit $exit_code) — see $log_file"
    FAILED_EXAMPLES+=("$relative (exit $exit_code)")
    (( FAILED++ )) || true
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
log "==============================="
log "Results: PASSED=$PASSED  FAILED=$FAILED  SKIPPED=$SKIPPED"
log "==============================="

if [[ $FAILED -gt 0 ]]; then
  err "The following examples failed:"
  for f in "${FAILED_EXAMPLES[@]}"; do
    err "  - $f"
  done
  exit 1
fi

log "All examples passed."
exit 0
