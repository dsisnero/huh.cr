#!/usr/bin/env crystal
require "../src/huh"

# Example demonstrating Cell-based value binding.
puts "=== Huh Cell API Example ==="

name = Huh.cell("")
age = Huh.cell("")
country = Huh.cell("")
newsletter = Huh.cell(false)
interests = Huh.cell([] of String)

form = Huh.new_form(
  Huh.new_group(
    Huh.new_input.title("What's your name?").value(name),
    Huh.new_input.title("Age").value(age)
  ),
  Huh.new_group(
    Huh.new_select(String)
      .title("Country")
      .options(Huh.new_options("US", "CA", "UK"))
      .value(country),
    Huh.new_multiselect(String)
      .title("Interests")
      .options(Huh.new_options("Programming", "Music", "Sports"))
      .value(interests)
  ),
  Huh.new_group(
    Huh.new_confirm.title("Subscribe to newsletter?").value(newsletter)
  )
)

form.run_accessible

puts "Name: #{name.value}"
puts "Age: #{age.value}"
puts "Country: #{country.value}"
puts "Interests: #{interests.value.join(", ")}"
puts "Newsletter: #{newsletter.value}"
