#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$0")/../scripts/check_source_parity.sh" "$@"
