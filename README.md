# huh

A Crystal port of the [charmbracelet/huh](https://github.com/charmbracelet/huh) Go library for building interactive forms and prompts in the terminal.

**This is a work in progress.** The goal is to provide a complete, idiomatic Crystal implementation that maintains API parity with the Go version while leveraging Crystal's strengths.

## About the Original Library

`huh?` is a simple, powerful library for building interactive forms and prompts in the terminal. The Go version features:

- **Easy form building** with groups and fields
- **Multiple field types**: Input, Text, Select, MultiSelect, Confirm
- **Accessibility mode** for screen readers
- **Theming support** with several built-in themes
- **Dynamic forms** that change based on previous input
- **Bubble Tea integration** for embedding in TUI applications
- **Standalone spinner package** for indicating background activity

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     huh:
       github: dsisnero/huh
   ```

2. Run `shards install`

## Usage

```crystal
require "huh"

# Coming soon - API will follow the Go version's patterns
```

## Porting Status

This library is actively being ported from the Go implementation. The Go source code is available as a submodule in `./vendor/` for reference.

**Current goals:**

- Maintain API parity with the Go version
- Produce identical output to match Go test fixtures
- Follow Crystal idioms and best practices
- Support the full feature set including accessibility, theming, and dynamic forms

## Development

To set up the development environment:

```bash
# Initialize the Go submodule reference
git submodule update --init --recursive

# Build and test with Crystal
crystal spec
```

The project follows the Model-Update-View architecture used by the Go version, adapted for Crystal's `Term2` library patterns.

## Contributing

1. Fork it (<https://github.com/dsisnero/huh/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Dominic Sisneros](https://github.com/dsisnero) - creator and maintainer

## Acknowledgments

This library ports the excellent [charmbracelet/huh](https://github.com/charmbracelet/huh) Go library by Charm Bracelet. The original library is inspired by the [Survey](https://github.com/AlecAivazis/survey) library by Alec Aivazis.

## License

MIT
