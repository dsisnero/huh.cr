#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/timer/main.go
puts "== Crystal Port: timer =="
form = Huh.new_form(Huh.new_group(
  Huh.new_input.title("Demo").placeholder("Port scaffold for Bubble Tea app")
))
form.run
