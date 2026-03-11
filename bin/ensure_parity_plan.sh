#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$0")/../scripts/ensure_parity_plan.sh" "$@"
