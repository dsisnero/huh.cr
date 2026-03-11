#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "usage: $0 <root_dir> <source_path> <language> <parser> <refresh>" >&2
  exit 1
fi

root_dir=$1
source_path=$2
language=$3
parser_mode=$4
refresh=$5

mkdir -p "$root_dir/plans/inventory"

inv="$root_dir/plans/inventory/${language}_port_inventory.tsv"
src_manifest="$root_dir/plans/inventory/${language}_source_parity.tsv"
test_manifest="$root_dir/plans/inventory/${language}_test_parity.tsv"

if [[ ! -f "$inv" || "$refresh" == "1" ]]; then
  "$root_dir/scripts/generate_port_inventory.sh" "$root_dir" "$inv" "$source_path" "$language" "$parser_mode"
fi

if [[ ! -f "$src_manifest" || "$refresh" == "1" ]]; then
  "$root_dir/scripts/generate_source_parity_manifest.sh" "$root_dir" "$src_manifest" "$source_path" "$language" "$parser_mode"
fi

if [[ ! -f "$test_manifest" || "$refresh" == "1" ]]; then
  "$root_dir/scripts/generate_test_parity_manifest.sh" "$root_dir" "$test_manifest" "$source_path" "$language" "$parser_mode"
fi

"$root_dir/scripts/check_port_inventory.sh" "$root_dir" "$inv" "$source_path" "$language" "$parser_mode"
"$root_dir/scripts/check_source_parity.sh" "$root_dir" "$src_manifest" "$source_path" "$language" "$parser_mode"
"$root_dir/scripts/check_test_parity.sh" "$root_dir" "$test_manifest" "$source_path" "$language" "$parser_mode"

echo "parity plan ready"
echo "  $inv"
echo "  $src_manifest"
echo "  $test_manifest"
