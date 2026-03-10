#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/skip/main.go
puts "== Crystal Port: skip =="
one = Huh.cell("")
two = Huh.cell("")
form = Huh.new_form(
  Huh.new_group(Huh.new_input.title("Group 1").value(one)),
  Huh.new_group(Huh.new_input.title("Group 2").value(two))
)
form.run
