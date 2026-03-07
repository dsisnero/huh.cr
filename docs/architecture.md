# Architecture

Port of Go huh library to Crystal - interactive forms library for terminal applications using Bubble Tea TUI framework.

## Project Structure

```
src/
├── huh/           # Main library modules
│   ├── confirm.cr
│   ├── field.cr
│   ├── form.cr
│   ├── group.cr
│   ├── input.cr
│   ├── multiselect.cr
│   ├── note.cr
│   ├── select.cr
│   ├── text.cr
│   ├── theme.cr
│   └── validate.cr
├── bubbles/       # Bubble Tea integration
└── huh.cr         # Main entry point

spec/
├── huh/           # Test specifications
│   ├── confirm_spec.cr
│   ├── input_spec.cr
│   ├── multiselect_spec.cr
│   └── select_spec.cr
├── spec_helper.cr
├── huh_spec.cr
└── golden_helper_spec.cr

vendor/            # Upstream Go source (submodule)
testdata/          # Golden test fixtures
temp/              # Temporary debug files
```

## Data Flow

1. **Form Creation**: User creates `Huh::Form` with fields (input, select, confirm, etc.)
2. **Field Configuration**: Each field has validation, styling, and interaction logic
3. **Bubble Tea Integration**: Forms are wrapped as Bubble Tea models
4. **Rendering**: Fields render using Lipgloss for terminal styling
5. **User Interaction**: Keyboard input processed through Bubble Tea update loop
6. **Validation**: Field values validated before form completion
7. **Completion**: Form returns collected values or errors

## Package/Module Responsibilities

- **`Huh`**: Main namespace and form orchestration
- **`Huh::Field`**: Base field functionality and common behavior
- **`Huh::Input`**: Text input field with validation
- **`Huh::Select`**: Single-select dropdown
- **`Huh::MultiSelect`**: Multi-select dropdown
- **`Huh::Confirm`**: Yes/No confirmation field
- **`Huh::Note`**: Informational text display
- **`Huh::Text`**: Multi-line text input
- **`Huh::Theme`**: Styling and theming configuration
- **`Huh::Validate`**: Validation functions and rules
- **`Bubbles`**: Bubble Tea integration layer