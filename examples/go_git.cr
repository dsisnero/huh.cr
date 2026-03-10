#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/git/main.go
puts "== Crystal Port: git =="
selected = Huh.cell("")
form = Huh.new_form(Huh.new_group(
  Huh.new_filepicker.title("Select a file").value(selected)
))
form.run
puts "Selected: #{selected.value}"
