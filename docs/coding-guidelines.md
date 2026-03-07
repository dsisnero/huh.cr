# Coding Guidelines

## Code Style

- Follow Crystal standard library conventions
- Use `crystal tool format` for consistent formatting
- Line length: aim for 80-100 characters
- Use 2-space indentation (Crystal default)

## Error Handling

- Use exceptions for unrecoverable errors
- Return `nil` or `Result` types for expected failure cases
- Match Go error semantics where applicable for parity
- Document error conditions in method signatures

## Naming Conventions

- **Modules**: `PascalCase` (e.g., `Huh::Input`)
- **Classes**: `PascalCase` (e.g., `Form`)
- **Methods**: `snake_case` (e.g., `validate_input`)
- **Variables**: `snake_case` (e.g., `field_value`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `DEFAULT_WIDTH`)

## Documentation

- Document public APIs with yardoc-style comments
- Include examples for complex methods
- Document behavioral parity with Go implementation
- Use `TODO:` comments for incomplete porting work

## Porting-Specific Guidelines

### Go to Crystal Mapping

| Go Construct | Crystal Equivalent | Notes |
|-------------|-------------------|-------|
| `package foo` | `module Foo` | |
| `func F() error` | `def f : Nil \| Exception` | Preserve error semantics |
| `[]byte` | `Bytes` (`Slice(UInt8)`) | For binary data |
| `map[string]T` | `Hash(String, T)` | |
| `panic("msg")` | `raise "msg"` | For unrecoverable errors |
| `interface{}` | Use union types or generics | Match Go behavior |

### Behavioral Parity

- Preserve exact output formatting (spacing, colors, etc.)
- Match Go's edge case handling
- Use same validation logic and error messages
- Keep API signatures identical where possible

### Testing

- Port Go tests to Crystal specs
- Use golden files for output comparison
- Test edge cases from Go implementation
- Ensure test fixtures produce identical output