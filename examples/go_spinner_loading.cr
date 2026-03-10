#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/spinner/examples/loading/main.go
puts "== Crystal Spinner Port: loading =="
Huh::Spinner.new
  .title("loading")
  .accessible(true)
  .action { }
  .run
