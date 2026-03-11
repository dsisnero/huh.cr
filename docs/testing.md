# Testing

## Running Tests

```bash
# Run all tests
make test

# Run specific test file
crystal spec spec/huh/input_spec.cr

# Run with verbose output
crystal spec --verbose
```

## Test Conventions

- Test files live in `spec/` directory
- File naming: `*_spec.cr` (e.g., `input_spec.cr`)
- Test structure follows Crystal's `spec` framework
- Use `describe` blocks for module/class grouping
- Use `it` blocks for individual test cases

## Writing Tests

### Golden File Tests

For parity verification with Go output:

```crystal
it "produces identical output to Go" do
  # Generate output
  output = generate_form_output

  # Compare with golden file
  golden = File.read("testdata/go/input_initial.txt")
  output.should eq(golden)
end
```

### Unit Tests

```crystal
describe Huh::Input do
  it "validates required field" do
    input = Huh.input("Name").required
    input.valid?.should be_false
    input.error.should contain("required")
  end
end
```

### Integration Tests

```crystal
describe "Form integration" do
  it "collects values from multiple fields" do
    form = Huh.form do |f|
      f.input("Name")
      f.select("Color", ["red", "blue", "green"])
    end

    # Simulate user input and form completion
    # ...
  end
end
```

## Coverage

- Aim for 100% behavioral parity with Go tests
- Port all Go test cases to Crystal specs
- Add characterization tests for untested Go behavior
- Use `temp/` directory for debug output during test development

## Golden Files

Golden files in `testdata/go/` are canonical:

- Generated from Go test output
- Must match exactly for parity verification
- Update when Go behavior changes (update submodule)
- Never modify manually - regenerate from Go
