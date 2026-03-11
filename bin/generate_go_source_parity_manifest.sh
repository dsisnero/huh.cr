#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 3 ]]; then
  echo "usage: $0 <repo_root> <output_tsv> <go_source_dir>" >&2
  exit 1
fi
exec "$(dirname "$0")/generate_source_parity_manifest.sh" "$1" "$2" "$3" go "${PORT_PARSER:-auto}"
