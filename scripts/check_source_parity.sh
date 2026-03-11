#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 || $# -gt 5 ]]; then
  echo "usage: $0 <repo_root> <manifest_tsv> <source_path> <language> [parser]" >&2
  exit 1
fi

repo_root=$1
manifest_tsv=$2
source_path=$3
language=$4
parser_mode=${5:-${PORT_PARSER:-auto}}

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

"$repo_root/scripts/generate_source_parity_manifest.sh" "$repo_root" "$tmp" "$source_path" "$language" "$parser_mode" >/dev/null

if diff -u "$manifest_tsv" "$tmp"; then
  echo "source parity check passed"
else
  echo "source parity drift detected" >&2
  exit 1
fi
