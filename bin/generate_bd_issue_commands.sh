#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "usage: $0 <repo_root> <manifest_tsv> <issue_type> [priority]" >&2
  exit 1
fi

repo_root=$1
manifest_tsv=$2
issue_type=$3
priority=${4:-2}

cd "$repo_root"

# Expected manifest columns: id kind path symbol status notes
# Skip header and create bd commands for non-ported items.
awk -F'\t' 'NR > 1 && $5 != "ported" {
  gsub(/"/, "\\\"", $4)
  gsub(/"/, "\\\"", $3)
  print "bd create --title=\"Port parity: " $4 "\" --type=" issue_type " --priority=" priority " --description=\"Go symbol: " $1 " (" $3 ") status=" $5 "\""
}' issue_type="$issue_type" priority="$priority" "$manifest_tsv"
