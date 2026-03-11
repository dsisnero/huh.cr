#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 || $# -gt 5 ]]; then
  echo "usage: $0 <repo_root> <inventory_tsv> <source_path> <language> [parser]" >&2
  exit 1
fi

repo_root=$1
inventory_tsv=$2
source_path=$3
language=$4
parser_mode=${5:-${PORT_PARSER:-auto}}

tmp=$(mktemp)
trap 'rm -f "$tmp" "$tmp.norm" "$inventory_tsv.norm"' EXIT

cp "$inventory_tsv" "$tmp" 2>/dev/null || true
"$repo_root/scripts/generate_port_inventory.sh" "$repo_root" "$tmp" "$source_path" "$language" "$parser_mode" >/dev/null

awk -F'\t' 'NR==1 { print "id\tkind\tpath\tsymbol"; next } { print $1"\t"$2"\t"$3"\t"$4 }' "$inventory_tsv" | sort -u > "$inventory_tsv.norm"
awk -F'\t' 'NR==1 { print "id\tkind\tpath\tsymbol"; next } { print $1"\t"$2"\t"$3"\t"$4 }' "$tmp" | sort -u > "$tmp.norm"

if diff -u "$inventory_tsv.norm" "$tmp.norm"; then
  echo "port inventory check passed"
else
  echo "port inventory drift detected" >&2
  exit 1
fi
