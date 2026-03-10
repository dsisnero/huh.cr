#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/readme/input/main.go
puts "== Crystal Port: readme/input =="
value = Huh.cell("")
form = Huh.new_form(Huh.new_group(Huh.new_input.title("Name").value(value)))
form.run
puts "Value: #{value.value}"
