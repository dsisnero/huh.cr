#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/readme/main/main.go
puts "== Crystal Port: readme/main =="
name = Huh.cell("")
ok = Huh.cell(false)
form = Huh.new_form(Huh.new_group(
  Huh.new_input.title("Name").value(name),
  Huh.new_confirm.title("Confirm").value(ok)
))
form.run
puts "Name: #{name.value}, Confirmed: #{ok.value}"
