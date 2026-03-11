#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$0")/../scripts/generate_port_inventory.sh" "$@"
