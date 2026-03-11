#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname "$0")/../scripts/verify_parity_adversarial.sh" "$@"
