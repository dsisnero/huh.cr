#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/layout/default/main.go
puts "== Crystal Port: layout/default =="

form = Huh.new_form(
  Huh.new_group(
    Huh.new_input.title("First"),
    Huh.new_input.title("Second"),
    Huh.new_input.title("Third")
  ),
  Huh.new_group(
    Huh.new_input.title("Fourth"),
    Huh.new_input.title("Fifth"),
    Huh.new_input.title("Sixth")
  ),
  Huh.new_group(
    Huh.new_input.title("Seventh"),
    Huh.new_input.title("Eigth"),
    Huh.new_input.title("Nineth"),
    Huh.new_input.title("Tenth")
  )
)

form.run
