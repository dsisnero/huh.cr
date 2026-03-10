#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/spinner/examples/accessible/main.go
puts "== Crystal Spinner Port: accessible =="
Huh::Spinner.new
  .title("accessible")
  .accessible(true)
  .action { }
  .run
