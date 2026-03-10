require "../spec_helper"
require "teatest"

module Huh
  describe "dynamic country teatest" do
    it "supports filtering country with / m enter and advances to next field" do
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

      tm = Teatest.new_test_model(Huh::RuntimeModel(Huh::Form).new(form), [
        Teatest.with_initial_term_size(80, 24),
      ])

      Teatest.wait_for(tm.output, ->(buffer : Bytes) {
        buffer.size > 0
      }, [
        Teatest.with_duration(2.seconds),
        Teatest.with_check_interval(10.milliseconds),
      ])

      tm.send(Tea.key('/'))
      sleep 20.milliseconds
      tm.send(Tea.key('m'))
      sleep 20.milliseconds
      tm.send(Tea.key(::Tea::KeyEnter))
      sleep 100.milliseconds

      Teatest.wait_for(tm.output, ->(buffer : Bytes) {
        String.new(buffer).includes?("Territory")
      }, [
        Teatest.with_duration(2.seconds),
        Teatest.with_check_interval(10.milliseconds),
      ])

      tm.send(Tea::QuitMsg.new)
      final_model = tm.final_model([Teatest.with_final_timeout(2.seconds)])
      final_model.should_not be_nil

      if model = final_model
        wrapped = model.as(Huh::RuntimeModel(Huh::Form))
        wrapped.model.selector.selected.selector.index.should eq(1)
      else
        fail "expected final model"
      end

      country.value.should eq("Mexico")
    end
  end
end
