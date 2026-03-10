# Huh User Guide

A comprehensive guide to using the Huh library for building interactive forms and prompts in the terminal.

## Quick Start

```crystal
require "huh"

# Create a simple form
name = ""
confirmed = false

form = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("What's your name?")
      .value(pointerof(name)),
    Huh.new_confirm
      .title("Are you sure?")
      .value(pointerof(confirmed))
  )
)

form.run
puts "Hello, #{name}!" if confirmed
```

## Core Concepts

### Forms
Forms are the top-level container for your interactive prompts. They organize fields into logical groups.

### Groups
Groups represent sections or "pages" of a form. Users navigate between groups using Tab/Shift+Tab.

### Fields
Fields are the individual input components (text inputs, selects, confirms, etc.).

## Field Types

### Input
Single-line text input for names, emails, or other short text.

```crystal
Huh.new_input
  .title("What's your name?")
  .placeholder("John Doe")
  .value(pointerof(name))
  .validate do |value|
    if value.empty?
      Exception.new("Name cannot be empty")
    end
  end
```

### Text
Multi-line text input for longer responses.

```crystal
Huh.new_text
  .title("Tell us about yourself")
  .char_limit(500)
  .lines(5)
  .value(pointerof(bio))
```

### Select
Choose a single option from a list.

```crystal
Huh.new_select(String)
  .title("Choose your country")
  .options([
    Huh::Option.new("United States", "US"),
    Huh::Option.new("Canada", "CA"),
    Huh::Option.new("Mexico", "MX")
  ])
  .value(pointerof(country))
```

### MultiSelect
Choose multiple options from a list.

```crystal
Huh.new_multiselect(String)
  .title("Choose toppings")
  .options([
    Huh::Option.new("Lettuce", "lettuce").selected(true),
    Huh::Option.new("Tomatoes", "tomatoes").selected(true),
    Huh::Option.new("Cheese", "cheese")
  ])
  .limit(4)
  .value(pointerof(toppings))
```

### Confirm
Yes/No confirmation prompt.

```crystal
Huh.new_confirm
  .title("Accept terms and conditions?")
  .affirmative("Yes, I agree")
  .negative("No, I decline")
  .value(pointerof(agreed))
```

### Note
Display informational text (non-interactive).

```crystal
Huh.new_note
  .title("Welcome!")
  .description("Please fill out the following form.\n\nPress Tab to navigate.")
```

## Complete Example: Burger Order Form

```crystal
require "huh"

# Variables to store form data
burger_type = ""
toppings = [] of String
name = ""
instructions = ""
discount = false

# Build the form
form = Huh.new_form(
  # Welcome note
  Huh.new_group(
    Huh.new_note
      .title("Charmburger")
      .description("Welcome to _Charmburger™_.\n\nHow may we take your order?\n\n")
      .next(true)
      .next_label("Next")
  ),

  # Burger selection
  Huh.new_group(
    Huh.new_select(String)
      .title("Choose your burger")
      .options([
        Huh::Option.new("Charmburger Classic", "classic"),
        Huh::Option.new("Chickwich", "chickwich"),
        Huh::Option.new("Fishburger", "fishburger")
      ])
      .value(pointerof(burger_type))
      .validate do |value|
        if value == "fishburger"
          Exception.new("No fish today, sorry")
        end
      end,

    Huh.new_multiselect(String)
      .title("Toppings")
      .description("Choose up to 4 toppings.")
      .options([
        Huh::Option.new("Lettuce", "lettuce").selected(true),
        Huh::Option.new("Tomatoes", "tomatoes").selected(true),
        Huh::Option.new("Cheese", "cheese"),
        Huh::Option.new("Bacon", "bacon"),
        Huh::Option.new("Avocado", "avocado")
      ])
      .limit(4)
      .value(pointerof(toppings))
  ),

  # Final details
  Huh.new_group(
    Huh.new_input
      .title("What's your name?")
      .placeholder("For when your order is ready")
      .value(pointerof(name))
      .validate do |value|
        if value == "Frank"
          Exception.new("No Franks, sorry")
        end
      end,

    Huh.new_text
      .title("Special Instructions")
      .placeholder("Just put it in the mailbox please")
      .char_limit(400)
      .lines(3)
      .value(pointerof(instructions)),

    Huh.new_confirm
      .title("Would you like 15% off?")
      .value(pointerof(discount))
      .affirmative("Yes!")
      .negative("No.")
  )
)

# Run the form
form.run

# Display results
puts "\nOrder Summary:"
puts "Burger: #{burger_type}"
puts "Toppings: #{toppings.join(", ")}"
puts "Name: #{name}"
puts "Instructions: #{instructions}"
puts "Discount: #{discount ? "Yes (15% off)" : "No"}"
```

## Validation

All field types support validation:

```crystal
Huh.new_input
  .title("Email")
  .value(pointerof(email))
  .validate do |value|
    unless value.includes?("@")
      Exception.new("Invalid email address")
    end
  end
```

## Dynamic Forms

Forms can change based on user input using `*_func` methods:

```crystal
country = ""
state = ""

form = Huh.new_form(
  Huh.new_group(
    Huh.new_select(String)
      .title("Country")
      .options([
        Huh::Option.new("United States", "US"),
        Huh::Option.new("Canada", "CA")
      ])
      .value(pointerof(country)),

    Huh.new_select(String)
      .title_func(->{ country == "US" ? "State" : "Province" }, pointerof(country))
      .options_func(->{
        case country
        when "US"
          ["California", "Texas", "New York"]
        when "CA"
          ["Ontario", "Quebec", "British Columbia"]
        else
          [] of String
        end.map { |name| Huh::Option.new(name, name.downcase) }
      }, pointerof(country))
      .value(pointerof(state))
  )
)
```

## Key Bindings

- **Tab/Enter**: Move to next field or group
- **Shift+Tab**: Move to previous field or group
- **Up/Down**: Navigate select options
- **Space**: Toggle selection in MultiSelect/Confirm
- **Ctrl+C**: Exit form
- **/** (in Select): Start filtering options

## Integration with Bubble Tea

Huh forms can be embedded in Bubble Tea applications:

```crystal
class MyApp
  include Bubbletea::Model

  @form : Huh::Form

  def initialize
    @form = Huh.new_form(
      Huh.new_group(
        Huh.new_input.title("Name"),
        Huh.new_confirm.title("Ready?")
      )
    )
  end

  def init
    @form.init
  end

  def update(msg)
    form, cmd = @form.update(msg)
    @form = form.as(Huh::Form)
    {self, cmd}
  end

  def view
    @form.view
  end
end
```

## Theming

Apply themes to customize appearance:

```crystal
theme = Huh::Theme.new
  .base(Huh::Style.new.foreground("#FFFFFF").background("#000000"))
  .title(Huh::Style.new.bold(true).foreground("#FF6B6B"))
  .description(Huh::Style.new.foreground("#888888"))

form = Huh.new_form(group).with_theme(theme)
```

## Accessibility

Enable accessible mode for screen readers:

```crystal
accessible = ENV["ACCESSIBLE"]? == "true"
form = Huh.new_form(group).with_accessible(accessible)
```

Accessible forms use standard prompts instead of TUI elements for better screen reader compatibility.

## Common Patterns

### Standalone Field Usage

Fields can be used without a form:

```crystal
name = ""
Huh.new_input
  .title("What's your name?")
  .value(pointerof(name))
  .run

puts "Hello, #{name}!"
```

### Form State Checking

Check if form is completed:

```crystal
form = Huh.new_form(group)
form.run

if form.state == :completed
  # Process form data
end
```

### Error Handling

```crystal
begin
  form.run
rescue ex
  puts "Error: #{ex.message}"
end
```

## Best Practices

1. **Group related fields**: Keep related fields in the same group
2. **Use validation**: Validate user input as early as possible
3. **Provide clear titles**: Make field purposes obvious
4. **Use placeholders**: Show expected format for inputs
5. **Limit options**: Keep select/multiselect options manageable
6. **Test accessibility**: Ensure forms work with screen readers

## Troubleshooting

**Form doesn't display**: Ensure terminal supports ANSI codes and is at least 80 columns wide.

**Input not captured**: Use `pointerof(variable)` for value binding, not just the variable.

**Validation errors**: Check that validation functions return `Exception` or `nil`, not `true`/`false`.

**Key bindings not working**: Some terminals may intercept certain key combinations.

## Next Steps

- Explore the [examples directory](../examples/) for more patterns
- Check [API documentation](../src/) for detailed method references
- Review [source code](https://github.com/dsisnero/huh) on GitHub