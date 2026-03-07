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

    # Coming soon - API will follow the Go version's patterns
    ```

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

This library is actively being ported from the Go implementation. The Go source code is available as a submodule in `./vendor/` for reference.

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