#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 3 ]]; then
  echo "usage: $0 <repo_root> <inventory_tsv> <go_source_dir>" >&2
  exit 1
fi
exec "$(dirname "$0")/check_port_inventory.sh" "$1" "$2" "$3" go "${PORT_PARSER:-auto}"
