#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/conditional/main.go
puts "== Crystal Port: conditional =="
ok = Huh.cell(false)
form = Huh.new_form(Huh.new_group(Huh.new_confirm.title("Continue?").value(ok)))
form.run
puts "Confirmed: #{ok.value}"
