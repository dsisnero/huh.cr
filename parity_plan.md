# Parity Completion Plan

This plan defines how to prove the Crystal port is complete and behaviorally faithful to upstream Go.

## 1. Hard Stop Conditions (must be true)

- `spec/` contains no pending placeholders (`pending`, `xit`, `xdescribe`, `xcontext`).
- All Crystal code gates pass.
- Go parity manifests are generated and checked for drift.
- Golden-output tests match Go behavior for covered scenarios.
- Any remaining parity gaps are explicitly tracked as `bd` tasks with rationale.

## 2. Pending/Placeholder Gate

Run:

```bash
rg -n "\\bpending\\b|xit\\(|xdescribe\\(|xcontext\\(" spec src
```

Pass criteria:

- No matches.

## 3. Upstream Inventory and Drift Gate

Goal: ensure every exported Go API item and Go test has a parity status.

### 3.1 Parity scripts in this repo

Use the generic scripts (with Go wrappers preserved):

- Generic: `generate_port_inventory.sh`, `check_port_inventory.sh`
- Generic: `generate_source_parity_manifest.sh`, `check_source_parity.sh`
- Generic: `generate_test_parity_manifest.sh`, `check_test_parity.sh`
- Lifecycle: `ensure_parity_plan.sh`, `verify_parity_adversarial.sh`
- Backward compatible Go wrappers: `generate_go_*`, `check_go_*`
- Backlog helper: `generate_bd_issue_commands.sh`

### 3.2 Generate manifests

Assuming upstream Go source lives under `vendor/huh/` (set exact path):

```bash
mkdir -p plans/inventory
./bin/generate_port_inventory.sh . plans/inventory/go_port_inventory.tsv <GO_SOURCE_DIR> go auto
./bin/generate_source_parity_manifest.sh . plans/inventory/go_source_parity.tsv <GO_SOURCE_DIR> go auto
./bin/generate_test_parity_manifest.sh . plans/inventory/go_test_parity.tsv <GO_SOURCE_DIR> go auto
```

### 3.3 Validate drift continuously

```bash
./bin/check_port_inventory.sh . plans/inventory/go_port_inventory.tsv <GO_SOURCE_DIR> go auto
./bin/check_source_parity.sh . plans/inventory/go_source_parity.tsv <GO_SOURCE_DIR> go auto
./bin/check_test_parity.sh . plans/inventory/go_test_parity.tsv <GO_SOURCE_DIR> go auto
```

Pass criteria:

- No unknown/new/stale IDs.
- Each exported Go item is classified (`ported`, `partial`, `in_progress`, `missing`, `skipped`) with rationale.

## 4. Behavior Parity Gate (Go vs Crystal output)

- Keep using golden tests under `testdata/go/` for stable UI output parity.
- For each field/component (input, confirm, select, multiselect, text, filepicker, note, spinner, form/group nav), ensure at least one executable parity spec exists.
- For complex flows, assert stripped output (`Ansi.strip`) and key state transitions.

Pass criteria:

- Golden tests pass.
- No untested component with parity-sensitive behavior.

## 5. Code Quality Gates (required each parity sweep)

```bash
CRYSTAL_CACHE_DIR=$PWD/.crystal-cache crystal tool format --check src spec
CRYSTAL_CACHE_DIR=$PWD/.crystal-cache ameba src spec
CRYSTAL_CACHE_DIR=$PWD/.crystal-cache crystal spec
rumdl fmt docs/ *.md
```

Pass criteria:

- All commands exit successfully.

## 6. Gap Tracking and Closure

For any item still `partial`/`missing`:

```bash
./bin/generate_bd_issue_commands.sh . plans/inventory/go_port_inventory.tsv task 2 > /tmp/bd_porting.sh
```

- Create/refresh `bd` tasks.
- Link each task to exact Go source/test identifiers.
- Close tasks only after parity spec + code gates pass.

## 7. Definition of Done

Port is considered complete when:

- Placeholder gate passes.
- Inventory + source/test drift checks pass.
- Behavior parity checks (including golden) pass.
- Crystal code gates pass.
- No remaining `bd` parity tasks except explicitly accepted skips with documented rationale.
