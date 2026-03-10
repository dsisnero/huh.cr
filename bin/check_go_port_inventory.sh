#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <repo_root> <inventory_tsv> <go_source_dir>" >&2
  exit 1
fi

repo_root=$1
inventory_tsv=$2
go_source_dir=$3

tmp_file=$(mktemp)
trap 'rm -f "$tmp_file"' EXIT

"$repo_root/bin/generate_go_port_inventory.sh" "$repo_root" "$tmp_file" "$go_source_dir" >/dev/null

if diff -u "$inventory_tsv" "$tmp_file"; then
  echo "inventory check passed"
else
  echo "inventory drift detected" >&2
  exit 1
fi
