require "../src/huh"

# Example demonstrating different layout options in Huh

puts "=== Huh Layout Examples ===\n\n"

# Example 1: Default layout (single group at a time)
puts "1. Default Layout (single group):"
name = Huh.cell("")
email = Huh.cell("")
newsletter = Huh.cell(false)

form1 = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("What's your name?")
      .value(name),
    Huh.new_input
      .title("What's your email?")
      .value(email)
  ),
  Huh.new_group(
    Huh.new_confirm
      .title("Subscribe to newsletter?")
      .value(newsletter)
  )
)

# Run in accessible mode for demonstration
form1.run_accessible
puts "Name: #{name.value}, Email: #{email.value}, Newsletter: #{newsletter.value}\n\n"

# Example 2: Stack layout (all groups stacked)
puts "2. Stack Layout (all groups stacked):"
age = Huh.cell("")
country = Huh.cell("")
interests = Huh.cell([] of String)

form2 = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("Age")
      .value(age)
      .validate { |v| v.to_i? ? nil : Exception.new("Must be a number") }
  ),
  Huh.new_group(
    Huh.new_select(String)
      .title("Country")
      .options([
        Huh::Option.new("USA", "USA"),
        Huh::Option.new("Canada", "Canada"),
        Huh::Option.new("UK", "UK"),
      ])
      .value(country)
  ),
  Huh.new_group(
    Huh.new_multiselect(String)
      .title("Interests")
      .options([
        Huh::Option.new("Programming", "Programming"),
        Huh::Option.new("Design", "Design"),
        Huh::Option.new("Music", "Music"),
        Huh::Option.new("Sports", "Sports"),
      ])
      .value(interests)
  )
).with_layout(Huh::Layout::LAYOUT_STACK)

# Run in accessible mode
form2.run_accessible
puts "Age: #{age.value}, Country: #{country.value}, Interests: #{interests.value}\n\n"

# Example 3: Columns layout (2 columns)
puts "3. Columns Layout (2 columns):"
username = Huh.cell("")
password = Huh.cell("")
confirm_password = Huh.cell("")
tos = Huh.cell(false)

form3 = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("Username")
      .value(username)
  ),
  Huh.new_group(
    Huh.new_input
      .title("Password")
      .value(password)
      .password
  ),
  Huh.new_group(
    Huh.new_input
      .title("Confirm Password")
      .value(confirm_password)
      .password
  ),
  Huh.new_group(
    Huh.new_confirm
      .title("Accept Terms of Service")
      .value(tos)
  )
).with_layout(Huh.layout_columns(2))

# Run in accessible mode
form3.run_accessible
puts "Username: #{username.value}, Password: #{password.value}, TOS: #{tos.value}\n\n"

# Example 4: Grid layout (2x2 grid)
puts "4. Grid Layout (2x2 grid):"
q1 = Huh.cell("")
q2 = Huh.cell("")
q3 = Huh.cell("")
q4 = Huh.cell("")

form4 = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("Question 1")
      .value(q1)
      .placeholder("Answer 1")
  ),
  Huh.new_group(
    Huh.new_input
      .title("Question 2")
      .value(q2)
      .placeholder("Answer 2")
  ),
  Huh.new_group(
    Huh.new_input
      .title("Question 3")
      .value(q3)
      .placeholder("Answer 3")
  ),
  Huh.new_group(
    Huh.new_input
      .title("Question 4")
      .value(q4)
      .placeholder("Answer 4")
  )
).with_layout(Huh.layout_grid(2, 2))

# Run in accessible mode
form4.run_accessible
puts "Answers: Q1=#{q1.value}, Q2=#{q2.value}, Q3=#{q3.value}, Q4=#{q4.value}\n\n"

puts "=== All examples completed ==="
