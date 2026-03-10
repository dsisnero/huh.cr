#!/usr/bin/env crystal
require "../src/huh"

# Simple example showing the clean Cell API

puts "=== Simple Huh Form Example ===\n"

# Create mutable references for form values
name = Huh.cell("")
email = Huh.cell("")
subscribe = Huh.cell(false)

# Build the form
form = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("What's your name?")
      .placeholder("Enter your name")
      .value(name),

    Huh.new_input
      .title("Email address")
      .placeholder("user@example.com")
      .value(email)
      .validate do |value|
        unless value.includes?("@")
          Exception.new("Please enter a valid email")
        end
      end
  ),

  Huh.new_group(
    Huh.new_confirm
      .title("Subscribe to newsletter?")
      .affirmative("Yes, please!")
      .negative("No thanks")
      .value(subscribe)
  )
)

puts "Form created with 2 groups:"
puts "  1. Name and email"
puts "  2. Newsletter subscription"
puts "\nThe form will run in accessible mode..."
puts "=" * 50

# Run in accessible mode (non-interactive for demo)
form.run_accessible

puts "\n" + "=" * 50
puts "FORM COMPLETED!"
puts "=" * 50
puts "\nResults:"
puts "  Name: #{name.value.empty? ? "(not provided)" : name.value}"
puts "  Email: #{email.value.empty? ? "(not provided)" : email.value}"
puts "  Newsletter: #{subscribe.value ? "SUBSCRIBED ✓" : "Not subscribed"}"
puts "\nNote: The values are stored in Cell containers that were"
puts "updated by the form. You can use them in your application."
