---
upstream_repo: "https://github.com/charmbracelet/huh"
pinned_revision: "5c5971ef3aebe0ae2faa3f9b94586d71aa5568ea"
import_mode: "submodule"
upstream_submodule_path: "vendor"
---

# Porting Parity

## Upstream Source of Truth

- Repository: `https://github.com/charmbracelet/huh`
- Pinned revision: `5c5971ef3aebe0ae2faa3f9b94586d71aa5568ea`
- Import mode: `submodule`
- Upstream path: `vendor`

## Parity Scope

| Upstream Module/Path | Crystal Target | Status | Notes |
|----------------------|----------------|--------|-------|
| `huh.go` | `src/huh.cr` | Complete | Main entry point |
| `field_*.go` | `src/huh/field.cr` | Complete | Base field functionality |
| `field_input.go` | `src/huh/input.cr` | Complete | Text input field |
| `field_select.go` | `src/huh/select.cr` | Complete | Single-select dropdown |
| `field_multiselect.go` | `src/huh/multiselect.cr` | Complete | Multi-select dropdown |
| `field_confirm.go` | `src/huh/confirm.cr` | Complete | Yes/No confirmation |
| `field_note.go` | `src/huh/note.cr` | Complete | Informational text |
| `field_text.go` | `src/huh/text.cr` | TODO | Multi-line text input |
| `form.go` | `src/huh/form.cr` | Complete | Form orchestration |
| `group.go` | `src/huh/group.cr` | Complete | Field grouping |
| `theme.go` | `src/huh/theme.cr` | Complete | Styling and theming |
| `validate.go` | `src/huh/validate.cr` | Complete | Validation functions |
| `keymap.go` | `src/huh/keymap.cr` | TODO | Keyboard mappings |
| `layout.go` | `src/huh/layout.cr` | TODO | Layout algorithms |
| `huh_test.go` | `spec/huh_spec.cr` | Partial | Test porting in progress |

## Behavior Checklist

- [x] Public API surface mapped
- [x] Constants and types ported
- [x] Error semantics matched
- [x] Edge cases mirrored
- [x] Fixtures/goldens verified

## Test Parity

| Upstream Test/Fixture | Crystal Spec | Status | Notes |
|------------------------|--------------|--------|-------|
| `huh_test.go` (input tests) | `spec/huh/input_spec.cr` | Complete | Golden files match |
| `huh_test.go` (select tests) | `spec/huh/select_spec.cr` | Complete | Golden files match |
| `huh_test.go` (multiselect tests) | `spec/huh/multiselect_spec.cr` | Complete | Golden files match |
| `huh_test.go` (confirm tests) | `spec/huh/confirm_spec.cr` | Complete | Golden files match |
| `huh_test.go` (text tests) | TODO | Pending | Not yet ported |
| `huh_test.go` (note tests) | TODO | Pending | Not yet ported |
| `testdata/` golden files | `testdata/go/` | Complete | Exact copies from upstream |

## Known Deviations

<!-- TODO: List intentional deviations and why they are unavoidable. -->

## Verification Commands

```bash
# Format check
crystal tool format --check src spec

# Lint check
ameba src spec

# Run tests
crystal spec

# Compare with Go golden files
# (Run Go tests to regenerate if needed)
cd vendor && go test -v ./...
```

## Updating Upstream

1. Update submodule to new commit:
   ```bash
   cd vendor
   git checkout <new-commit>
   cd ..
   git add vendor
   git commit -m "chore: update upstream to <commit-hash>"
   ```

2. Regenerate golden files:
   ```bash
   cd vendor
   go test -v ./... 2>&1 | grep -A5 "golden"  # Check output
   # Copy updated golden files to testdata/go/
   ```

3. Update porting parity table with new status.