#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/burger/main.go
enum Spice
  Mild
  Medium
  Hot
end

struct Burger
  property type : String
  property toppings : Array(String)
  property spice : Spice

  def initialize(
    @type = "",
    @toppings = [] of String,
    @spice = Spice::Mild,
  )
  end
end

struct Order
  property burger : Burger
  property side : String
  property name : String
  property instructions : String
  property discount : Bool

  def initialize(
    @burger = Burger.new,
    @side = "",
    @name = "",
    @instructions = "",
    @discount = false,
  )
  end
end

puts "== Crystal Port: burger =="
form = Huh.new_form(Huh.new_group(
  Huh.new_input.title("Demo").placeholder("Port scaffold for Bubble Tea app")
))
form.run
