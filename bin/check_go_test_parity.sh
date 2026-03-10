#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <repo_root> <manifest_tsv> <go_source_dir>" >&2
  exit 1
fi

repo_root=$1
manifest_tsv=$2
go_source_dir=$3

tmp_file=$(mktemp)
trap 'rm -f "$tmp_file"' EXIT

"$repo_root/bin/generate_go_test_parity_manifest.sh" "$repo_root" "$tmp_file" "$go_source_dir" >/dev/null

if diff -u "$manifest_tsv" "$tmp_file"; then
  echo "test parity manifest check passed"
else
  echo "test parity drift detected" >&2
  exit 1
fi
