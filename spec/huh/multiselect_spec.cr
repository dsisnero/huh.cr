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

    it "updates filter keymap states while filtering" do
      keymap = Huh::KeyMap.new
      sel = Huh.new_multiselect(String).keymap(keymap)
      select_map = sel.keymap.not_nil!

      sel.filtering(true)
      select_map.set_filter.enabled?.should be_true
      select_map.filter.enabled?.should be_false
      select_map.next.enabled?.should be_false
      select_map.submit.enabled?.should be_false
      select_map.prev.enabled?.should be_false
    end

    it "submits selection and advances with enter" do
      first = Huh.new_multiselect(String)
        .options(Huh.new_options("A", "B", "C", "D"))
      second = Huh.new_input.title("Next field")
      form = Huh.new_form(Huh.new_group(first, second))
      form.init

      model, _ = form.update(Tea.key('G'))
      form = model
      model, _ = form.update(Tea.key(' '))
      form = model
      model, cmd = form.update(Tea.key(::Tea::KeyEnter))
      form = model
      if cmd
        if msg = cmd.call
          model, _ = form.update(msg)
          form = model
        end
      end

      first.get_value.should eq(["D"])
      form.selector.selected.selector.index.should eq(1)
    end

    it "supports goto top/bottom and half-page movement" do
      sel = Huh.new_multiselect(String)
        .height(4)
        .options(Huh.new_options("A", "B", "C", "D", "E"))
      sel.init

      sel.update(Tea.key('G'))
      sel.update(Tea.key(' '))
      sel.get_value.should eq(["E"])

      sel.update(Tea.key('g'))
      sel.update(Tea.key(' '))
      sel.get_value.sort.should eq(["A", "E"])

      sel.update(Tea.key('d', Tea::ModCtrl))
      sel.update(Tea.key(' '))
      sel.get_value.sort.should eq(["A", "C", "E"])
    end
  end
end
