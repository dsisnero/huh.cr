#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <repo_root> <output_tsv> <go_source_dir>" >&2
  exit 1
fi

repo_root=$1
output_tsv=$2
go_source_dir=$3

{
  echo -e "id\tpath\ttest_name\tstatus\tnotes"
  rg -n --no-heading --glob '*_test.go' '^func\s+Test[A-Za-z0-9_]+' "$go_source_dir" | \
    perl -ne 'if (/^([^:]+):\d+:func\s+(Test[A-Za-z0-9_]+)/) { print "$1:$2\t$1\t$2\n"; }' | \
    sort -u | while IFS=$'\t' read -r id path test_name; do
      status="missing"
      notes=""
      if rg -q --glob '*.cr' "${test_name}|${test_name#Test}" "$repo_root/spec"; then
        status="ported"
        notes="matching spec name found"
      else
        notes="no matching spec name found"
      fi
      echo -e "${id}\t${path}\t${test_name}\t${status}\t${notes}"
    done
} > "$output_tsv"

echo "wrote $output_tsv"
