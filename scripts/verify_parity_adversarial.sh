#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 || $# -gt 5 ]]; then
  echo "usage: $0 <root_dir> <source_path> <language> [crystal_test_cmd] [upstream_test_cmd]" >&2
  exit 1
fi

root_dir=$1
source_path=$2
language=$3
crystal_cmd=${4:-}
upstream_cmd=${5:-}

"$root_dir/scripts/ensure_parity_plan.sh" "$root_dir" "$source_path" "$language" auto 0

inv="$root_dir/plans/inventory/${language}_port_inventory.tsv"

awk -F'\t' '
  NR > 1 {
    status=$5
    refs=$6
    if ((status == "ported" || status == "partial") && refs == "") {
      print "missing crystal_refs for id: " $1 > "/dev/stderr"
      bad=1
    }
  }
  END { exit bad ? 1 : 0 }
' "$inv"

if rg -n '\bpending\b|xit\(|xdescribe\(|xcontext\(' "$root_dir/spec" "$root_dir/src"; then
  echo "placeholder tests/spec markers detected" >&2
  exit 1
fi

if [[ -n "$crystal_cmd" && "$crystal_cmd" != "-" ]]; then
  (cd "$root_dir" && eval "$crystal_cmd")
fi

if [[ -n "$upstream_cmd" && "$upstream_cmd" != "-" ]]; then
  (cd "$root_dir" && eval "$upstream_cmd")
fi

echo "adversarial parity verification passed"
