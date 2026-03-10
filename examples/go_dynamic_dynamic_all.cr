#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/dynamic/dynamic-all/main.go
puts "== Crystal Port: dynamic/dynamic-all =="
items = Huh.cell([] of String)
form = Huh.new_form(Huh.new_group(
  Huh.new_multiselect(String)
    .title("Select items")
    .options(Huh.new_options("One", "Two", "Three"))
    .value(items)
))
form.run
puts "Items: #{items.value.join(", ")}"
