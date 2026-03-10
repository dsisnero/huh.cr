#!/usr/bin/env crystal
require "../src/huh"

# Simple form example
puts "=== Basic Huh Form Example ===\n"

name = Huh.cell("")
email = Huh.cell("")
country = Huh.cell("")
bio = Huh.cell("")
agreed = Huh.cell(false)

form = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("What's your name?")
      .placeholder("John Doe")
      .value(name)
      .validate do |value|
        if value.empty?
          Exception.new("Name cannot be empty")
        end
      end,

    Huh.new_input
      .title("Email address")
      .placeholder("john@example.com")
      .value(email)
      .validate do |value|
        unless value.includes?("@")
          Exception.new("Invalid email address")
        end
      end
  ),

  Huh.new_group(
    Huh.new_select(String)
      .title("Choose your country")
      .options([
        Huh::Option.new("United States", "US"),
        Huh::Option.new("Canada", "CA"),
        Huh::Option.new("United Kingdom", "UK"),
        Huh::Option.new("Australia", "AU"),
      ])
      .value(country),

    Huh.new_text
      .title("Tell us about yourself")
      .description("Write a short bio (optional)")
      .char_limit(200)
      .lines(3)
      .value(bio)
  ),

  Huh.new_group(
    Huh.new_confirm
      .title("Agree to terms and conditions?")
      .affirmative("Yes, I agree")
      .negative("No, I decline")
      .value(agreed)
      .validate do |value|
        unless value
          Exception.new("You must agree to continue")
        end
      end
  )
)

puts "\nRunning form in accessible mode...\n"
form.run_accessible

puts "\n=== Form Results ==="
puts "Name: #{name.value}"
puts "Email: #{email.value}"
puts "Country: #{country.value}"
puts "Bio: #{bio.value.empty? ? "(empty)" : bio.value}"
puts "Agreed to terms: #{agreed.value ? "Yes" : "No"}"
