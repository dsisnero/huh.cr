#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/readme/note/main.go
puts "== Crystal Port: readme/note =="
form = Huh.new_form(Huh.new_group(
  Huh.new_note.title("Info").description("This is the Crystal port scaffold for this Go example.")
))
form.run
