<p align="center">
  <strong>Port of Go huh library to Crystal</strong><br>
  Interactive forms library for terminal applications
</p>

<p align="center">
  <a href="docs/architecture.md">Architecture</a> &middot;
  <a href="docs/development.md">Development</a> &middot;
  <a href="docs/coding-guidelines.md">Guidelines</a> &middot;
  <a href="docs/testing.md">Testing</a> &middot;
  <a href="docs/pr-workflow.md">PR Workflow</a> &middot;
  <a href="docs/porting-parity.md">Porting Parity</a>
</p>

---

The "huh!" moment when a complex form becomes simple - making terminal interactions intuitive and delightful.

---

A Crystal port of the [charmbracelet/huh](https://github.com/charmbracelet/huh) Go library for building interactive forms and prompts in the terminal.

**This is a work in progress.** The goal is to provide a complete, idiomatic Crystal implementation that maintains API parity with the Go version while leveraging Crystal's strengths.

## Quick Start

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     huh:
       github: dsisnero/huh
   ```

2. Run `shards install`

3. Basic usage:

    ```crystal
    require "huh"

    # Create a simple form using Cell for mutable values
    name = Huh.cell("")
    confirmed = Huh.cell(false)

    form = Huh.new_form(
      Huh.new_group(
        Huh.new_input
          .title("What's your name?")
          .value(name),
        Huh.new_confirm
          .title("Are you sure?")
          .value(confirmed)
      )
    )

    form.run
    puts "Hello, #{name.value}!" if confirmed.value
    ```

## Value Binding with Cell

Huh uses `Cell` containers for mutable value binding. Since Crystal's `String` and other basic types are value types (structs), we need a wrapper to allow fields to update them.

### Using `Huh.cell()`

```crystal
# Create mutable references
name = Huh.cell("")           # Cell(String)
age = Huh.cell(0)             # Cell(Int32)
active = Huh.cell(false)      # Cell(Bool)
tags = Huh.cell([] of String) # Cell(Array(String))

# Use with fields
field.value(name)

# Access values after form completion
form.run
puts "Name: #{name.value}"
```

### Why Cell instead of pointers?

- **Type-safe** - Compile-time type checking
- **Crystal-idiomatic** - No raw pointer arithmetic
- **Clean API** - `Huh.cell("")` is readable
- **Go compatibility** - Also supports `Pointer(T)` for Go parity

### Field Types and Cell Types

| Field Type | Cell Type | Example |
|------------|----------|---------|
| `Input` | `Cell(String)` | `Huh.cell("")` |
| `Text` | `Cell(String)` | `Huh.cell("")` |
| `Select(T)` | `Cell(T)` | `Huh.cell("")` (where T is selected value type) |
| `MultiSelect(T)` | `Cell(Array(T))` | `Huh.cell([] of String)` |
| `Confirm` | `Cell(Bool)` | `Huh.cell(false)` |
| `FilePicker` | `Cell(String)` | `Huh.cell("")` |

## Features

- **Easy form building** with groups and fields
- **Multiple field types**: Input, Text, Select, MultiSelect, Confirm
- **Accessibility mode** for screen readers
- **Theming support** with several built-in themes
- **Dynamic forms** that change based on previous input
- **Bubble Tea integration** for embedding in TUI applications
- **Standalone spinner package** for indicating background activity

## Development

```bash
# Install dependencies
make install

# Run tests
make test

# Check formatting
make format

# Lint code
make lint

# Format markdown documentation
make markdown
```

See [Development Guide](docs/development.md) for full setup instructions.

## Documentation

| Document | Purpose |
|----------|---------|
| [Architecture](docs/architecture.md) | System design and data flow |
| [Development](docs/development.md) | Setup and daily workflow |
| [Coding Guidelines](docs/coding-guidelines.md) | Code style and conventions |
| [Testing](docs/testing.md) | Test commands and patterns |
| [PR Workflow](docs/pr-workflow.md) | Commits, PRs, and review process |
| [Porting Parity](docs/porting-parity.md) | Upstream source tracking and behavior verification |

## Porting Status

This library is actively being ported from the Go implementation. The Go source code is available as a submodule in `./vendor/huh/` for reference.

**Current goals:**

- Maintain API parity with the Go version
- Produce identical output to match Go test fixtures
- Follow Crystal idioms and best practices
- Support the full feature set including accessibility, theming, and dynamic forms

## Contributing

1. Create an issue: `/forge-create-issue`
2. Implement: `/forge-implement-issue <number>`
3. Self-review: `/forge-reflect-pr`
4. Address feedback: `/forge-address-pr-feedback`
5. Update changelog: `/forge-update-changelog`

## Contributors

- [Dominic Sisneros](https://github.com/dsisnero) - creator and maintainer

## Acknowledgments

This library ports the excellent [charmbracelet/huh](https://github.com/charmbracelet/huh) Go library by Charm Bracelet. The original library is inspired by the [Survey](https://github.com/AlecAivazis/survey) library by Alec Aivazis.

## License

MIT
