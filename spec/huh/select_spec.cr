require "../spec_helper"
require "../../src/huh"

module Huh
  describe Select(String) do
    it "can be created and configured" do
      sel = Huh.new_select(String)
        .title("Choose a fruit")
        .description("Pick your favorite")
        .options(Huh.new_options("Apple", "Banana", "Cherry"))

      sel.should be_a(Select(String))
      sel.title.should eq("Choose a fruit")
      sel.description.should eq("Pick your favorite")
    end

    it "has default values" do
      sel = Huh.new_select(String)
      sel.get_value.should eq("") # default empty string for String type
      sel.options([] of Option(String))
      sel.get_value.should eq("")
    end

    it "can set value via cell" do
      cell = Cell(String).new("Apple")
      sel = Huh.new_select(String).value(cell)
      sel.get_value.should eq("Apple")

      cell.value = "Banana"
      sel.get_value.should eq("Banana")
    end

    it "selects option matching value" do
      sel = Huh.new_select(String)
        .options(Huh.new_options("Apple", "Banana", "Cherry"))
        .value(Cell(String).new("Banana"))

      sel.get_value.should eq("Banana")
      # TODO: check internal selected index
    end

    it "filters options" do
      sel = Huh.new_select(String)
        .options(Huh.new_options("Apple", "Apricot", "Banana"))
        .filtering(true)
      # TODO: implement filtering test after filtering logic is ready
    end

    it "matches golden file for basic select" do
      # Create select field with same options as golden file
      select_field = Huh.new_select(String)
        .title("Choose a color")
        .options(Huh.new_options("Red", "Green", "Blue"))

      # Create form with group (as done in golden generator)
      form = Huh.new_form(Huh.new_group(select_field))

      # Initialize the form
      form.init

      # Get the view and strip ANSI codes like Go tests do
      view = Ansi.strip(form.view)

      # Compare with golden file
      Golden.require_equal("select_initial", view, "testdata/go")
    end

    it "submits from filtering mode with enter" do
      first = Huh.new_select(String)
        .title("Country")
        .options(Huh.new_options("United States", "Canada", "Mexico"))
      second = Huh.new_input.title("Next field")
      form = Huh.new_form(Huh.new_group(first, second))
      form.init

      model, _ = form.update(Tea.key('/'))
      form = model
      model, _ = form.update(Tea.key('M'))
      form = model
      model, cmd = form.update(Tea.key(::Tea::KeyEnter))
      form = model
      if cmd
        if msg = cmd.call
          model, _ = form.update(msg)
          form = model
        end
      end

      first.get_value.should eq("Mexico")
      form.selector.selected.selector.index.should eq(1)
    end
  end
end
