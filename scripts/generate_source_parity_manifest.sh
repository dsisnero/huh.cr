#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 || $# -gt 5 ]]; then
  echo "usage: $0 <repo_root> <output_tsv> <source_path> <language> [parser]" >&2
  exit 1
fi

repo_root=$1
output_tsv=$2
source_path=$3
language=$4
parser_mode=${5:-${PORT_PARSER:-auto}}

inv=$(mktemp)
trap 'rm -f "$inv"' EXIT

"$repo_root/scripts/generate_port_inventory.sh" "$repo_root" "$inv" "$source_path" "$language" "$parser_mode" >/dev/null

{
  cat templates/source_parity.tsv
  tail -n +2 "$inv" | while IFS=$'\t' read -r id kind path symbol _status _refs _notes; do
    status="missing"
    notes="no symbol match in src/spec"
    if rg -q --glob '*.cr' "\\b${symbol}\\b" "$repo_root/src" "$repo_root/spec"; then
      status="ported"
      notes="symbol match found in Crystal source/spec"
    fi
    echo -e "${id}\t${kind}\t${path}\t${symbol}\t${status}\t${notes}"
  done
} > "$output_tsv"

echo "wrote $output_tsv"
