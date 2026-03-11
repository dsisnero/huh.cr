#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 || $# -gt 5 ]]; then
  echo "usage: $0 <repo_root> <output_tsv> <source_path> <language> [parser]" >&2
  exit 1
fi

repo_root=$1
output_tsv=$2
source_path=$3
language=$4
parser_mode=${5:-${PORT_PARSER:-auto}}

inv=$(mktemp)
trap 'rm -f "$inv"' EXIT

to_snake_case() {
  local s=$1
  printf '%s' "$s" | sed -E 's/([A-Z]+)([A-Z][a-z])/\1_\2/g; s/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

symbol_patterns() {
  local symbol=$1
  local patterns=("$symbol")

  # Go constructor funcs (NewX) map to Crystal new_x helpers.
  if [[ "$symbol" =~ ^New[A-Z] ]]; then
    local ctor=${symbol#New}
    patterns+=("new_$(to_snake_case "$ctor")")
    patterns+=("$ctor")
  fi

  # Go exported vars like ErrTimeout map to Crystal exception classes.
  if [[ "$symbol" =~ ^Err[A-Z] ]]; then
    local err_name=${symbol#Err}
    patterns+=("${err_name}Error")
    patterns+=("$(to_snake_case "$err_name")_error")
  fi

  # Exported funcs map to snake_case in Crystal.
  patterns+=("$(to_snake_case "$symbol")")

  printf '%s\n' "${patterns[@]}" | awk '!seen[$0]++'
}

"$repo_root/scripts/generate_port_inventory.sh" "$repo_root" "$inv" "$source_path" "$language" "$parser_mode" >/dev/null

{
  cat templates/source_parity.tsv
  tail -n +2 "$inv" | while IFS=$'\t' read -r id kind path symbol _status _refs _notes; do
    status="missing"
    notes="no symbol match in src/spec"
    while IFS= read -r pattern; do
      if rg -q --glob '*.cr' "\\b${pattern}\\b" "$repo_root/src" "$repo_root/spec" "$repo_root/examples"; then
        status="ported"
        if [[ "$pattern" == "$symbol" ]]; then
          notes="symbol match found in Crystal source/spec/examples"
        else
          notes="idiomatic Crystal match found via ${pattern}"
        fi
        break
      fi
    done < <(symbol_patterns "$symbol")
    if [[ "$id" == "vendor/huh/accessor.go:NewPointerAccessor" ]]; then
      notes="idiomatic Crystal match via Huh.cell + PointerAccessor (ref renamed to cell)"
    fi
    echo -e "${id}\t${kind}\t${path}\t${symbol}\t${status}\t${notes}"
  done
} > "$output_tsv"

echo "wrote $output_tsv"
