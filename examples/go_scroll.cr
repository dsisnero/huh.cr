#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/scroll/main.go
puts "== Crystal Port: scroll =="
text = Huh.cell("")
form = Huh.new_form(Huh.new_group(
  Huh.new_text.title("Notes").lines(4).value(text)
))
form.run
puts "Text: #{text.value}"
