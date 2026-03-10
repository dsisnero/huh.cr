#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/spinner/examples/context/main.go
puts "== Crystal Spinner Port: context =="
Huh::Spinner.new
  .title("context")
  .accessible(true)
  .action { }
  .run
