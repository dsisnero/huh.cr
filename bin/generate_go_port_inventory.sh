#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <repo_root> <output_tsv> <go_source_dir>" >&2
  exit 1
fi

repo_root=$1
output_tsv=$2
go_source_dir=$3

cd "$repo_root"

{
  echo -e "id\tkind\tpath\tsymbol"
  rg -n --no-heading --glob '*.go' '^(func|type|const|var)\s+([A-Z][A-Za-z0-9_]*)' "$go_source_dir" | \
    perl -ne 'if (/^([^:]+):\d+:(func|type|const|var)\s+([A-Z][A-Za-z0-9_]*)/) { print "$1:$3\t$2\t$1\t$3\n"; }' | \
    sort -u
} > "$output_tsv"

echo "wrote $output_tsv"
