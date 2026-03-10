#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/dynamic/dynamic-increment/main.go
puts "== Crystal Port: dynamic/dynamic-increment =="
one = Huh.cell("")
two = Huh.cell("")
form = Huh.new_form(
  Huh.new_group(Huh.new_input.title("Group 1").value(one)),
  Huh.new_group(Huh.new_input.title("Group 2").value(two))
)
form.run
