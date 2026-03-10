#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/spinner/examples/static/main.go
puts "== Crystal Spinner Port: static =="
Huh::Spinner.new
  .title("static")
  .accessible(true)
  .action { }
  .run
