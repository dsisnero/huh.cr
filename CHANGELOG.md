# Changelog

All notable user-facing changes to this project will be documented in this file.

Changes are grouped by release date and category. Only user-facing changes are included — internal refactors, test updates, and CI changes are omitted.

## 2026-03-10

### Added
- **Dynamic form parity coverage**: Added executable parity checks for dynamic country filtering and submit flow (`/`, `m`, `enter`) to prevent regressions.
- **Layout parity coverage**: Added executable checks for default, stack, columns, and grid layout rendering behavior.

### Fixed
- **Form footer behavior**: Help and error footer rendering now matches upstream Go behavior when toggling show-help/show-errors.
- **Select and MultiSelect filtering flow**: Enter-to-submit from filtering mode and filter keymap state transitions now align with Go behavior.
- **Input suggestions behavior**: Suggestion visibility and accept-suggestion key binding behavior now follows upstream expectations.
- **Theme palette parity**: Dracula, Base16, and Catppuccin themes now use upstream palette behavior instead of fallback aliases.

### Changed
- **Cell API naming**: Pointer-like API usage is standardized on `Huh.cell(...)` across examples and docs for clearer Crystal-style call sites.
- **Examples parity set**: Go example ports were expanded/updated to improve source-to-source parity and runnable coverage.

## 2026-02-11

### Added
- **Theme system**: Implement theme system with integration for Input, Confirm, MultiSelect, and Note fields
- **MultiSelect field**: Add MultiSelect field implementation for multiple selection
- **Select field**: Implement Select field with options, filtering, and inline mode
- **Input field**: Initial implementation of Input field with Form/Group scaffolding
- **Foundation**: Phase 1 foundation implementation with basic project structure

### Fixed
- **Select field**: Improvements and spec fixes for Select field
- **Placeholder test**: Fix placeholder test to pass

### Changed
- **Project structure**: Update .gitignore with .crystal-cache and temp directory
- **Documentation**: Add porting plan and create issue tracking
