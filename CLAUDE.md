# huh

A simple, powerful library for building interactive forms and prompts in the terminal. Port of Go huh library to Crystal.

## Commands

```bash
# Install dependencies
make install

# Update dependencies
make update

# Check formatting
make format

# Lint code (fix and check)
make lint

# Run tests
make test

# Format markdown files
make markdown

# Check markdown formatting
make markdown-check

# Clean temporary files
make clean
```

## Documentation

| Document | Purpose |
|----------|---------|
| [Architecture](docs/architecture.md) | System design, data flow, package responsibilities |
| [Development](docs/development.md) | Prerequisites, setup, daily workflow |
| [Coding Guidelines](docs/coding-guidelines.md) | Code style, error handling, naming conventions |
| [Testing](docs/testing.md) | Test commands, conventions, patterns |
| [PR Workflow](docs/pr-workflow.md) | Commits, PRs, branch naming, review process |
| [Porting Parity](docs/porting-parity.md) | Upstream source tracking and behavior verification |

## Core Principles

1. Upstream Go code is source of truth
2. Golden files must match Go output
3. API parity is required
4. Use Go source for edge cases
5. When in doubt, consult Go source
6. Never simplify or skip functionality
7. Never change golden files or ported tests - tests are source of truth

## Commits

Format: `<type>(<scope>): <description>`

Types: feat, fix, docs, refactor, test, chore, perf

Examples:

- feat(input): add placeholder support
- fix(select): handle empty options list
- docs: update porting parity documentation

## Crystal Code Gates

```bash
crystal tool format --check src spec
ameba src spec
crystal spec
rumdl fmt docs/ *.md
```

## Code Modification Tools

### fastmod for Bulk Code Changes

For bulk code modifications across multiple files, use `fastmod` (a Rust tool for fast code modification):

```bash
# Check if fastmod is installed
if ! command -v fastmod &> /dev/null; then
  echo "fastmod not found, installing via cargo..."
  cargo install fastmod
fi

# View fastmod help to understand usage
fastmod --help
```

**Common fastmod patterns:**

- `fastmod -d . 'old_pattern' 'new_pattern'` - Dry run to see changes
- `fastmod 'old_pattern' 'new_pattern' --extensions cr,md` - Replace in specific file types
- `fastmod --accept-all 'old_pattern' 'new_pattern'` - Apply changes without confirmation

**When to use fastmod:**

- Renaming variables/functions across multiple files
- Updating import statements
- Changing API signatures
- Bulk documentation updates

**Note:** Always run a dry run first (`-d` flag) to preview changes before applying them.

## External Dependencies

- **Upstream Go library**: `vendor/` submodule pinned to specific commit
- **Crystal shards**: lipgloss, golden, teatest, bubbles for Bubble Tea TUI framework
- **Development tools**: ameba for linting, rumdl for markdown formatting

## Debugging

When something breaks:

1. Check `temp/` directory for debug scripts and output
2. Run `make clean` to clear artifacts before re-running tests
3. Compare output with Go golden files in `testdata/go/`
4. Use `CRYSTAL_CACHE_DIR=$PWD/.crystal-cache` for consistent caching
5. Consult upstream Go implementation in `vendor/` for behavioral details

## Conventions

- All tests live under `spec/` directory
- Every new/modified source file under `src/` must have corresponding specs
- Temporary files must be in `./temp` directory (not system temp)
- Use beads (bd) for issue tracking: `bd ready`, `bd create`, `bd close`, `bd sync`
- Follow porting-to-crystal workflow for behavior-faithful translations
