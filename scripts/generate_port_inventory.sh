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

case "$language" in
  go|rust|crystal|java|ruby) ;;
  *)
    echo "unsupported language: $language" >&2
    exit 1
    ;;
esac

if [[ "$parser_mode" == "tree-sitter" ]]; then
  echo "warning: tree-sitter parser mode requested; falling back to regex" >&2
fi

cd "$repo_root"

raw=$(mktemp)
trap 'rm -f "$raw" "$raw.data" "$raw.merged" "$raw.old"' EXIT

extract_go() {
  rg -n --no-heading --glob '*.go' '^(func|type|const|var)\s+([A-Z][A-Za-z0-9_]*)' "$source_path" |
    perl -ne 'if (/^([^:]+):\d+:(func|type|const|var)\s+([A-Z][A-Za-z0-9_]*)/) { print "$1:$3\t$2\t$1\t$3\n"; }'
}

extract_rust() {
  rg -n --no-heading --glob '*.rs' '^\s*pub\s+(fn|struct|enum|trait|const|type)\s+([A-Za-z_][A-Za-z0-9_]*)' "$source_path" |
    perl -ne 'if (/^([^:]+):\d+:\s*pub\s+(fn|struct|enum|trait|const|type)\s+([A-Za-z_][A-Za-z0-9_]*)/) { print "$1:$3\t$2\t$1\t$3\n"; }'
}

extract_crystal() {
  rg -n --no-heading --glob '*.cr' '^\s*(class|module|struct|enum|alias|def|macro)\s+([A-Za-z_][A-Za-z0-9_!?=]*)' "$source_path" |
    perl -ne 'if (/^([^:]+):\d+:\s*(class|module|struct|enum|alias|def|macro)\s+([A-Za-z_][A-Za-z0-9_!?=]*)/) { print "$1:$3\t$2\t$1\t$3\n"; }'
}

extract_java() {
  rg -n --no-heading --glob '*.java' '^\s*public\s+' "$source_path" |
    perl -ne '
      if (/^([^:]+):\d+:\s*public\s+(?:class|interface|enum|@interface)\s+([A-Za-z_][A-Za-z0-9_]*)/) {
        print "$1:$2\ttype\t$1\t$2\n";
      } elsif (/^([^:]+):\d+:\s*public\s+(?:static\s+)?(?:final\s+)?[A-Za-z0-9_<>,\[\] ?]+\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/) {
        print "$1:$2\tfunc\t$1\t$2\n";
      }
    '
}

extract_ruby() {
  rg -n --no-heading --glob '*.rb' '^\s*(class|module|def)\s+' "$source_path" |
    perl -ne '
      if (/^([^:]+):\d+:\s*class\s+([A-Z][A-Za-z0-9_:]*)/) {
        print "$1:$2\ttype\t$1\t$2\n";
      } elsif (/^([^:]+):\d+:\s*module\s+([A-Z][A-Za-z0-9_:]*)/) {
        print "$1:$2\tmodule\t$1\t$2\n";
      } elsif (/^([^:]+):\d+:\s*def\s+(?:self\.)?([A-Za-z_][A-Za-z0-9_!?=]*)/) {
        print "$1:$2\tfunc\t$1\t$2\n";
      }
    '
}

case "$language" in
  go) extract_go ;;
  rust) extract_rust ;;
  crystal) extract_crystal ;;
  java) extract_java ;;
  ruby) extract_ruby ;;
esac | sort -u > "$raw.data"

{
  echo -e "id\tkind\tpath\tsymbol"
  cat "$raw.data" | while IFS=$'\t' read -r id kind path symbol; do
    echo -e "$id\t$kind\t$path\t$symbol"
  done
} > "$raw"

if [[ -s "$output_tsv" ]]; then
  awk -F'\t' '
    NR==FNR {
      if (FNR > 1) {
        status[$1]=$5
        refs[$1]=$6
        notes[$1]=$7
      }
      next
    }
    FNR==1 { print; next }
    {
      s=(($1 in status) ? status[$1] : "missing")
      r=(($1 in refs) ? refs[$1] : "-")
      n=(($1 in notes) ? notes[$1] : "-")
      if (r == "") r="-"
      if (n == "") n="-"
      print $1"\t"$2"\t"$3"\t"$4"\t"s"\t"r"\t"n
    }
  ' "$output_tsv" "$raw" > "$raw.merged"
  mv "$raw.merged" "$output_tsv"
else
  awk -F'\t' 'FNR==1 { print $0"\tstatus\tcrystal_refs\tnotes"; next } { print $0"\tmissing\t-\t-" }' "$raw" > "$output_tsv"
fi

echo "wrote $output_tsv"
