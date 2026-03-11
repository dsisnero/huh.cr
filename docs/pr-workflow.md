# PR Workflow

## Commit Conventions

Format: `<type>(<scope>): <description>`

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring (no behavior change)
- `test`: Test additions or updates
- `chore`: Maintenance tasks
- `perf`: Performance improvements

**Scopes:** Use module/component name (e.g., `input`, `select`, `theme`)

### Examples

- `feat(input): add placeholder support`
- `fix(select): handle empty options list`
- `docs: update porting parity documentation`
- `test(multiselect): add golden file tests`
- `chore: update dependencies`

## Branch Naming

Format: `<type>/<issue-number>-<short-kebab-description>`

### Examples

- `feat/42-add-input-validation`
- `fix/57-select-empty-options`
- `docs/23-update-porting-guide`

## PR Checklist

- [ ] Code follows project guidelines (see [Coding Guidelines](coding-guidelines.md))
- [ ] Tests added/updated (see [Testing](testing.md))
- [ ] Documentation updated (if applicable)
- [ ] CHANGELOG.md updated for user-facing changes
- [ ] Lint/format checks pass (`make format`, `make lint`)
- [ ] All tests pass (`make test`)
- [ ] Golden files match Go output (if porting changes)
- [ ] Upstream parity verified (check `vendor/huh/` submodule)

## Review Process

1. **Self-review**: Run `/forge-reflect-pr` before requesting review
2. **Create PR**: Use GitHub CLI or web interface
3. **Address feedback**: Use `/forge-address-pr-feedback` for systematic review
4. **Update changelog**: Use `/forge-update-changelog` before merging
5. **Merge**: Squash or merge based on project conventions

## Porting-Specific Review

For porting changes, reviewers should verify:

1. **Behavioral parity**: Output matches Go golden files
2. **API compatibility**: Public API matches Go equivalent
3. **Edge cases**: All Go edge cases handled
4. **Test coverage**: Go tests ported to Crystal specs
5. **Documentation**: Parity decisions documented in `docs/porting-parity.md`
