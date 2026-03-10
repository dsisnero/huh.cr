#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <repo_root> <output_tsv> <go_source_dir>" >&2
  exit 1
fi

repo_root=$1
output_tsv=$2
go_source_dir=$3

inv=$(mktemp)
trap 'rm -f "$inv"' EXIT
"$repo_root/bin/generate_go_port_inventory.sh" "$repo_root" "$inv" "$go_source_dir" >/dev/null

{
  echo -e "id\tkind\tpath\tsymbol\tstatus\tnotes"
  tail -n +2 "$inv" | while IFS=$'\t' read -r id kind path symbol; do
    status="missing"
    notes=""
    if rg -q --glob '*.cr' "\b${symbol}\b" "$repo_root/src" "$repo_root/spec"; then
      status="ported"
      notes="symbol found in Crystal source/spec"
    else
      notes="no symbol match found"
    fi
    echo -e "${id}\t${kind}\t${path}\t${symbol}\t${status}\t${notes}"
  done
} > "$output_tsv"

echo "wrote $output_tsv"
