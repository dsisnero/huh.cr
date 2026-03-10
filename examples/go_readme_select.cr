#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/readme/select/main.go
puts "== Crystal Port: readme/select =="
country = Huh.cell("")
form = Huh.new_form(Huh.new_group(
  Huh.new_select(String)
    .title("Country")
    .options(Huh.new_options("US", "CA", "UK"))
    .value(country)
))
form.run
puts "Country: #{country.value}"
