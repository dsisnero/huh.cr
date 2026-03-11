#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$0")/../scripts/generate_source_parity_manifest.sh" "$@"
