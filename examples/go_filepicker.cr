#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/filepicker/main.go
puts "== Crystal Port: filepicker =="

file = Huh.cell("")

form = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("Name")
      .description("What's your name?"),
    Huh.new_input
      .title("Username")
      .description("Select your username."),
    Huh.new_filepicker
      .title("Profile")
      .description("Select your profile picture.")
      .allowed_types([".png", ".jpeg", ".webp", ".gif"])
      .value(file),
    Huh.new_input
      .title("Password")
      .password
      .description("Set your Password.")
  )
)

form.run
puts "Selected file: #{file.value}"
