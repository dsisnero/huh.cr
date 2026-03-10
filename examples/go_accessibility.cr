#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/accessibility/main.go
puts "== Crystal Port: accessibility =="
name = Huh.cell("")
form = Huh.new_form(Huh.new_group(Huh.new_input.title("Accessible input").value(name)))
form.with_accessible(true).run
puts "Name: #{name.value}"
