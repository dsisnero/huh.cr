#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/theme/main.go
puts "== Crystal Port: theme =="
form = Huh.new_form(Huh.new_group(
  Huh.new_input.title("Demo").placeholder("Port scaffold for Bubble Tea app")
))
form.run
