require "../spec_helper"

module Huh
  describe MultiSelect(String) do
    it "can be created and configured" do
      sel = Huh.new_multiselect(String)
        .title("Choose fruits")
        .description("Pick multiple favorites")
        .options(Huh.new_options("Apple", "Banana", "Cherry"))

      sel.should be_a(MultiSelect(String))
      sel.title.should eq("Choose fruits")
      sel.description.should eq("Pick multiple favorites")
    end

    it "has default empty array value" do
      sel = Huh.new_multiselect(String)
      sel.get_value.should eq([] of String)
      sel.options([] of Option(String))
      sel.get_value.should eq([] of String)
    end

    it "can set value via cell" do
      cell = Cell(Array(String)).new(["Apple"])
      sel = Huh.new_multiselect(String).value(cell)
      sel.get_value.should eq(["Apple"])

      cell.value = ["Banana"]
      sel.get_value.should eq(["Banana"])
    end

    it "can set limit" do
      sel = Huh.new_multiselect(String).limit(2)
      sel.limit.should eq(2)
    end

    it "can set filterable" do
      sel = Huh.new_multiselect(String).filterable(false)
      sel.filterable?.should be_false
    end
  end
end
