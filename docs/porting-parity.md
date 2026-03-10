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
| `field_input.go` | `src/huh/fields/input.cr` | Complete | Text input field |
| `field_select.go` | `src/huh/fields/select.cr` | Partial | Selection parity present; page navigation and viewport scrolling still differ |
| `field_multiselect.go` | `src/huh/fields/multiselect.cr` | Partial | Core selection/filtering ported; viewport scrolling behavior still differs |
| `field_confirm.go` | `src/huh/fields/confirm.cr` | Complete | Yes/No confirmation |
| `field_note.go` | `src/huh/fields/note.cr` | Partial | Rendering parity covered; interactive key handling and dynamic update behavior still limited |
| `field_text.go` | `src/huh/fields/text.cr` | Complete | Multi-line text input |
| `field_filepicker.go` | `src/huh/fields/filepicker.cr` | Partial | Field shape exists; selected-path propagation parity incomplete |
| `form.go` | `src/huh/form.cr` | Complete | Form orchestration |
| `group.go` | `src/huh/form.cr` (`Huh::Group`) | Partial | Group core behavior ported; hidden-group APIs and some cross-group transitions differ |
| `theme.go` | `src/huh/theme.cr` | Complete | Styling and theming |
| `keymap.go` | `src/huh/keymap.cr` | Complete | Keymap definitions ported for all supported fields |
| `layout.go` | `src/huh/layout.cr` | Complete | Default/stack/columns/grid layouts implemented |
| `huh_test.go` | `spec/huh/go_parity_spec.cr` | Complete | Executable parity coverage with no pending cases |

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
| `huh_test.go` (text tests) | `spec/huh/text_spec.cr`, `spec/huh/go_parity_spec.cr` | Complete | Dedicated field specs plus parity flow coverage |
| `huh_test.go` (note tests) | `spec/huh/go_parity_spec.cr` | Complete | Note rendering and update-path parity checks added |
| `testdata/` golden files | `testdata/go/` | Complete | Exact copies from upstream |

## Known Deviations

- Hidden-group APIs (`hide`, `hide_func`) are not implemented in `Huh::Group`.
- Form timeout/context abort (`RunWithContext` style behavior) is not implemented.
- Select/multiselect page navigation parity (`g`, `G`, `ctrl+d`, `ctrl+u`) is incomplete.
- File picker does not yet propagate selected path from the internal Bubbles model.
- Note field interactive key handling and dynamic update message handling are minimal.
- Spinner interactive runtime path (`run_interactive`) is intentionally not implemented yet.
- Standalone `FieldBase#run` is currently unimplemented.

## Verification Commands

```bash
# Format check
CRYSTAL_CACHE_DIR=$PWD/.crystal-cache crystal tool format --check src spec

# Lint check
CRYSTAL_CACHE_DIR=$PWD/.crystal-cache ameba src spec

# Run tests
CRYSTAL_CACHE_DIR=$PWD/.crystal-cache crystal spec

# Ensure no pending/disabled tests
rg -n "\bpending\b|xit\(|xdescribe\(|xcontext\(" spec src

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
