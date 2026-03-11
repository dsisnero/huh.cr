# Development

## Prerequisites

- Crystal >= 1.19.1
- Git (for submodule management)
- Make (for build commands)
- rumdl (for markdown formatting): Install via Rust/Cargo: `cargo install rumdl`
- fastmod (for bulk code modifications): Install via Rust/Cargo: `cargo install fastmod`

## Setup

1. Clone repository with submodules:

   ```bash
   git clone --recurse-submodules https://github.com/dsisnero/huh.git
   cd huh
   ```

2. Install dependencies:

   ```bash
   make install
   ```

3. Verify setup:

   ```bash
   make test
   ```

## Daily Workflow

1. **Start work session**:

   ```bash
   bd ready  # Find unblocked work
   ```

2. **Make changes**:
   - Edit files in `src/`
   - Add corresponding tests in `spec/`

3. **Run quality gates**:

   ```bash
   make format
   make lint
   make test
   ```

4. **Debug issues**:
   - Check `temp/` directory for debug scripts
   - Compare with Go golden files in `testdata/go/`

5. **End work session**:

   ```bash
   bd sync
   git pull --rebase
   git push
   ```

## Temporary Files

All temporary files generated during development, testing, or build processes should be placed in the `temp/` directory. This directory is gitignored and can be cleaned with:

```bash
make clean  # Removes temp/** files
```

## Available Commands

| Command | Purpose |
|---------|---------|
| `make install` | Install Crystal dependencies |
| `make update` | Update dependencies to latest versions |
| `make format` | Check Crystal code formatting |
| `make lint` | Lint code with ameba (fix and check) |
| `make test` | Run all tests |
| `make markdown` | Format markdown files |
| `make markdown-check` | Check markdown formatting |
| `make clean` | Clean temporary files |

## Porting Workflow

When porting Go functionality:

1. **Reference upstream**: Check `vendor/huh/` submodule for Go implementation
2. **Create test first**: Port Go test to Crystal spec
3. **Implement behavior**: Translate Go logic to Crystal preserving semantics
4. **Verify parity**: Compare output with Go golden files
5. **Run gates**: Ensure all quality checks pass
