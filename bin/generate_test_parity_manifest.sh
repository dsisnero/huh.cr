#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$0")/../scripts/generate_test_parity_manifest.sh" "$@"
