#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/scroll/main.go
struct Pokemon
  property id : Int32
  property name : String

  def initialize(@id : Int32, @name : String)
  end

  def to_s(io : IO) : Nil
    io << @name
  end
end

puts "== Crystal Port: scroll =="
text = Huh.cell("")
form = Huh.new_form(Huh.new_group(
  Huh.new_text.title("Notes").lines(4).value(text)
))
form.run
puts "Text: #{text.value}"
