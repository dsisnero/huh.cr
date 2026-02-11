# Porting Plan: charmbracelet/huh from Go to Crystal

## Overview

This document outlines the strategy for porting the [charmbracelet/huh](https://github.com/charmbracelet/huh) Go library to Crystal while maintaining API parity, behavioral correctness, and visual fidelity. The Go implementation serves as the authoritative source (available as a submodule in `./vendor`).

## Goals

1. **API Parity**: Public APIs should match Go equivalents in behavior and semantics
2. **Visual Fidelity**: Output must match Go golden test fixtures exactly (including ANSI sequences)
3. **Crystal Idioms**: Use Crystal's strengths while preserving the original architecture
4. **Feature Completeness**: Support all field types, theming, accessibility, dynamic forms, and layouts

## Reference Sources

- **Go Source**: `./vendor/` submodule (commit 5c5971e, v0.8.0)
- **Golden Files**: Test fixtures in Go `testdata/` directories (to be captured)
- **Documentation**: Original Go documentation and examples

## Architecture Analysis

### Core Components (Go → Crystal Mapping)

| Go Component | Purpose | Crystal Approach |
|--------------|---------|-----------------|
| `bubbletea` | TUI framework (Model-Update-View) | Implement minimal Bubble Tea-like framework or adapt existing Crystal TUI |
| `lipgloss` | Terminal styling | Create Crystal Lipgloss port or equivalent styling engine |
| `bubbles/*` | UI components (textinput, textarea, etc.) | Re-implement each component with identical behavior |
| `huh.Form` | Form orchestration | Direct port with Crystal generics |
| `huh.Group` | Field container/page | Direct port |
| `huh.Field` interface | All field types | Interface with Crystal module |
| `internal/selector` | Navigation logic | Direct port with generics |
| `internal/accessibility` | Screen reader prompts | Port using Crystal IO/termios |
| `spinner/` | Loading indicator | Standalone Crystal implementation |

### Key Dependencies to Replace

1. **Bubble Tea (tea)**: Message loop, Model interface, Program execution
2. **Lip Gloss**: Styles, borders, colors, adaptive colors, layout
3. **Bubbles**:
   - `textinput`: Single-line input with suggestions
   - `textarea`: Multi-line input with external editor
   - `viewport`: Scrollable viewport
   - `filepicker`: File/directory picker
   - `spinner`: Loading animation
   - `help`: Help key binding display
4. **Hashstructure**: Caching for dynamic content (can use Crystal's `Object#hash` with limitations)
5. **Catppuccin/go**: Color schemes (can embed as constants)

## Phase 1: Foundation (Weeks 1-2)

### 1.1 Setup Test Infrastructure
- Create test harness that runs Go tests and captures golden outputs
- Establish comparison utilities for ANSI sequences
- Set up pseudo-terminal (pty) testing environment

### 1.2 Implement Core Abstractions
- **Field Interface**: `Field(T)` with `init`, `update`, `view`, `run_accessible`
- **Accessor Pattern**: Generic `Accessor(T)` for value storage
- **Selector**: Generic navigation for groups and fields
- **Eval System**: Cached evaluation with binding hashing

### 1.3 Create Minimal TUI Framework
- **Message System**: `Msg` base class, `KeyMsg`, `WindowSizeMsg`
- **Command Pattern**: `Cmd` as `Proc(Msg?)` or lambda
- **Program Loop**: Event handling, rendering cycle, resize handling
- **Viewport**: Basic scrolling container

### 1.4 Implement Basic Styling Engine
- **Style Class**: Color, border, padding, margin, alignment
- **Adaptive Colors**: Terminal color detection
- **Rendering Pipeline**: Combine styles hierarchically

## Phase 2: First Field Implementation (Weeks 3-4)

### 2.1 Input Field
- Single-line text input with cursor
- Character limit, echo modes (normal, password, none)
- Suggestions and validation
- Accessible mode support

### 2.2 Validation System
- `Validate` callbacks with error display
- Built-in validators: not empty, min/max length, one-of

### 2.3 Basic Form Navigation
- Simple form with single group
- Next/previous field navigation
- Submit/abort handling

### 2.4 Golden Test Verification
- Capture Go Input field outputs
- Ensure Crystal renders identical ANSI sequences
- Test with various terminal sizes

## Phase 3: Field Types Expansion (Weeks 5-8)

### 3.1 Select Field
- Single option selection from list
- Filtering, inline mode
- Option display with selected indicator
- Dynamic options via `OptionsFunc`

### 3.2 MultiSelect Field
- Multiple option selection
- Select all/none, limit constraints
- Toggle behavior

### 3.3 Confirm Field
- Yes/No toggle with custom labels
- Simple keyboard navigation

### 3.4 Text Field
- Multi-line text area
- External editor support (via $EDITOR)
- Character limit with counter

### 3.5 Note Field
- Read-only informational display
- Optional "Next" button

### 3.6 FilePicker Field
- File/directory selection
- Filtering by extension
- Navigation through filesystem

## Phase 4: Advanced Features (Weeks 9-12)

### 4.1 Theming System
- **Theme Structure**: Hierarchical styles (form, group, field, focused/blurred)
- **Built-in Themes**: Charm, Dracula, Base16, Catppuccin, Default
- **Theme Application**: Propagation and override rules

### 4.2 Layouts
- **Layout Interface**: `View(Form)` and `GroupWidth` methods
- **Built-in Layouts**: Default (paged), Stack, Columns, Grid
- **Viewport Integration**: Scrolling within layouts

### 4.3 Dynamic Forms
- **Binding System**: `TitleFunc`, `DescriptionFunc`, `OptionsFunc`
- **Caching**: Hash-based invalidation
- **Reactive Updates**: Automatic re-render on binding changes

### 4.4 Accessibility Mode
- **Detection**: Environment variable or explicit flag
- **Prompt Functions**: Direct IO prompting for each field type
- **Integration**: `run_accessible` method on all fields

## Phase 5: Polish and Integration (Weeks 13-16)

### 5.1 Key Mapping
- Customizable key bindings
- Context-sensitive keys (first/last field, group boundaries)
- Help key display

### 5.2 Error Handling
- Validation error display
- Timeout handling
- Graceful abort

### 5.3 Performance Optimization
- Efficient re-rendering
- Memory management for large forms
- Async operations (spinners, file loading)

### 5.4 Documentation
- API documentation with examples
- Migration guide from Go version
- Tutorials and cookbook

## Testing Strategy

### Golden File Verification
```
# Process for each feature:
1. Run Go tests to capture reference outputs
2. Store in `testdata/go/` directory
3. Implement Crystal feature
4. Run Crystal tests that compare against golden files
5. Fail if outputs don't match exactly
```

### Test Categories
1. **Unit Tests**: Individual components in isolation
2. **Integration Tests**: Complete forms with simulated input
3. **Accessibility Tests**: Screen reader mode
4. **Theme Tests**: Visual output for each built-in theme
5. **Layout Tests**: Different group arrangements
6. **Dynamic Tests**: Forms with reactive bindings

### Test Tools Needed
- **PTY Emulation**: For reproducible terminal interactions
- **ANSI Parser**: To compare escape sequences
- **Screenshot Comparison**: Visual diffing of terminal output
- **Input Simulation**: Programmatic key press simulation

## Crystal-Specific Considerations

### Generics Usage
- Fields: `Field(T)` where T is value type
- Select: `Select(T)` for option values
- Accessor: `Accessor(T)` interface
- Use Crystal's generic system with type restrictions

### Error Handling
- Use Crystal's exception system
- Return `nil` or raise based on context
- Maintain Go's error return patterns where appropriate

### Concurrency
- Use `spawn` and `Channel` for async operations
- Implement `Cmd` pattern with fiber-based execution
- Handle terminal signals gracefully

### File Structure
```
src/
├── huh/
│   ├── form.cr
│   ├── group.cr
│   ├── fields/
│   │   ├── field.cr (interface)
│   │   ├── input.cr
│   │   ├── select.cr
│   │   ├── multi_select.cr
│   │   ├── confirm.cr
│   │   ├── text.cr
│   │   ├── file_picker.cr
│   │   └── note.cr
│   ├── option.cr
│   ├── theme.cr
│   ├── keymap.cr
│   ├── layout.cr
│   ├── accessor.cr
│   ├── eval.cr
│   ├── validate.cr
│   └── wrap.cr
├── tui/                    # Bubble Tea-like framework
│   ├── model.cr
│   ├── msg.cr
│   ├── cmd.cr
│   ├── program.cr
│   └── viewport.cr
├── lipgloss/              # Styling engine
│   ├── style.cr
│   ├── color.cr
│   ├── border.cr
│   └── adaptive.cr
└── bubbles/              # UI components
    ├── text_input.cr
    ├── text_area.cr
    ├── viewport.cr
    ├── file_picker.cr
    ├── spinner.cr
    └── help.cr
```

## Risk Assessment

### High Risk
1. **ANSI Sequence Parity**: Exact match required for golden files
2. **Terminal Compatibility**: Different terminal emulator behaviors
3. **Performance**: Real-time rendering at 60fps

### Medium Risk
1. **Generic System Limitations**: Crystal's generics vs Go's
2. **Concurrency Model**: Fiber-based vs goroutine-based async
3. **External Dependencies**: PTY handling, termios compatibility

### Low Risk
1. **Business Logic**: Form navigation, validation
2. **Data Structures**: Options, themes, layouts
3. **API Design**: Fluent interface patterns

## Success Metrics

1. **Golden File Pass Rate**: 100% match for all test cases
2. **API Coverage**: All public methods from Go version implemented
3. **Performance**: Comparable rendering speed to Go version
4. **Memory Usage**: No memory leaks in long-running forms
5. **Documentation**: Complete API docs with examples

## Timeline Estimate

- **Phase 1 (Foundation)**: 2 weeks
- **Phase 2 (First Field)**: 2 weeks
- **Phase 3 (Field Types)**: 4 weeks
- **Phase 4 (Advanced Features)**: 4 weeks
- **Phase 5 (Polish)**: 4 weeks
- **Buffer/Contingency**: 4 weeks

**Total Estimated Time**: 20 weeks (5 months)

## Next Immediate Actions

1. **Set up golden file capture**: Run Go test suite and save outputs
2. **Create minimal TUI proof of concept**: Basic message loop and rendering
3. **Implement Field interface**: Core abstraction with accessible mode
4. **Build test harness**: Comparison utilities for ANSI sequences
5. **Start with Input field**: Most basic field type

## References

- [Go huh source](./vendor/)
- [Bubble Tea documentation](https://github.com/charmbracelet/bubbletea)
- [Lip Gloss documentation](https://github.com/charmbracelet/lipgloss)
- [Crystal Shards registry](https://crystalshards.org/)
- [Term2 library patterns](../AGENTS.md#api-conventions)