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

    pending "matches golden file for basic select" do
      # TODO: Implement golden test when theming is ready
    end
  end
end
