#!/usr/bin/env crystal
require "../src/huh"

# Dynamic form example showing live reevaluation across fields.

puts "=== Dynamic Form Example ===\n"

name = Huh.cell("")

form = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("What's your name?")
      .placeholder("Enter your name")
      .value(name),

    Huh.new_note
      .title_func(-> { "Greeting for #{name.value.empty? ? "friend" : name.value}" })
      .description_func(-> { "Hello, #{name.value.empty? ? "friend" : name.value}!" }),

    Huh.new_text
      .title_func(-> { "Tell us about #{name.value.empty? ? "yourself" : name.value}" })
      .description_func(-> { "Write a short bio for #{name.value.empty? ? "you" : name.value}" })
      .placeholder_func(-> { "Bio for #{name.value.empty? ? "you" : name.value}" })
      .lines(3)
  )
)

puts "Type in the first field and watch other fields update live."
puts "\nRunning form in accessible mode..."
puts "=" * 50

form.run_accessible

puts "\n" + "=" * 50
puts "Form completed!"
puts "Name entered: #{name.value}"
