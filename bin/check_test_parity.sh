#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$0")/../scripts/check_test_parity.sh" "$@"
