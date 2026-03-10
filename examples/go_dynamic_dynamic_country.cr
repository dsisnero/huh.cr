#!/usr/bin/env crystal
require "../src/huh"

# Port of vendor/examples/dynamic/dynamic-country/main.go
puts "== Crystal Port: dynamic/dynamic-country =="

country = Huh.cell("United States")
state = Huh.cell("")

states = {
  "United States" => ["Alabama", "Alaska", "Arizona", "California", "Colorado"],
  "Canada"        => ["Alberta", "British Columbia", "Ontario", "Quebec"],
  "Mexico"        => ["Aguascalientes", "Chiapas", "Jalisco", "Yucatán"],
}

form = Huh.new_form(
  Huh.new_group(
    Huh.new_select(String)
      .title("Country")
      .height(5)
      .options(Huh.new_options("United States", "Canada", "Mexico"))
      .value(country),
    Huh.new_select(String)
      .height(8)
      .title_func(-> {
        case country.value
        when "United States"
          "State"
        when "Canada"
          "Province"
        else
          "Territory"
        end
      })
      .options_func(-> {
        Huh.new_options(states[country.value]? || [] of String)
      })
      .value(state)
  )
)

form.run
puts "#{state.value}, #{country.value}"
