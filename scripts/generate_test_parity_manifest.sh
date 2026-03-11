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

if [[ "$parser_mode" == "tree-sitter" ]]; then
  echo "warning: tree-sitter parser mode requested; falling back to regex" >&2
fi

cd "$repo_root"

extract_go_tests() {
  rg -n --no-heading --glob '*_test.go' '^func\s+Test[A-Za-z0-9_]+' "$source_path" |
    perl -ne 'if (/^([^:]+):\d+:func\s+(Test[A-Za-z0-9_]+)/) { print "$1:$2\t$1\t$2\n"; }'
}

extract_rust_tests() {
  rg -n --no-heading --glob '*.rs' '^\s*#\[test\]' "$source_path" -A 2 |
    perl -ne '
      if (/^([^:]+)-\d+-\s*fn\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/) {
        print "$1:$2\t$1\t$2\n";
      }
    '
}

extract_crystal_tests() {
  rg -n --no-heading --glob '*_spec.cr' '^\s*it\s+"' "$source_path" |
    perl -ne 'if (/^([^:]+):\d+:\s*it\s+"([^"]+)"/) { my $name=$2; $name =~ s/\s+/_/g; print "$1:$name\t$1\t$name\n"; }'
}

extract_java_tests() {
  rg -n --no-heading --glob '*.java' '@Test|void\s+test[A-Za-z0-9_]+' "$source_path" -A 2 |
    perl -ne '
      if (/^([^:]+)-\d+-\s*(?:public\s+)?void\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/) {
        print "$1:$2\t$1\t$2\n";
      }
    '
}

extract_ruby_tests() {
  rg -n --no-heading --glob '*_test.rb' '^\s*def\s+test_[A-Za-z0-9_]+' "$source_path" |
    perl -ne 'if (/^([^:]+):\d+:\s*def\s+(test_[A-Za-z0-9_]+)/) { print "$1:$2\t$1\t$2\n"; }'
}

rows=$(mktemp)
trap 'rm -f "$rows"' EXIT

case "$language" in
  go) extract_go_tests ;;
  rust) extract_rust_tests ;;
  crystal) extract_crystal_tests ;;
  java) extract_java_tests ;;
  ruby) extract_ruby_tests ;;
  *) echo "unsupported language: $language" >&2; exit 1 ;;
esac | sort -u > "$rows"

{
  cat templates/test_parity.tsv
  while IFS=$'\t' read -r id path test_name; do
    status="missing"
    notes="no matching Crystal spec token"
    if rg -q --glob '*.cr' "${test_name}|${test_name#Test}|${test_name#test_}" "$repo_root/spec"; then
      status="ported"
      notes="matching token found in Crystal specs"
    fi
    echo -e "${id}\t${path}\t${test_name}\t${status}\t${notes}"
  done < "$rows"
} > "$output_tsv"

echo "wrote $output_tsv"
