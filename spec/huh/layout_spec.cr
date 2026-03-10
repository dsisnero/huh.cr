require "../spec_helper"
require "ansi"

module Huh
  describe "Layout parity" do
    it "default layout shows only selected group" do
      form = Huh.new_form(
        Huh.new_group(Huh.new_input.title("First")),
        Huh.new_group(Huh.new_input.title("Second"))
      )
      form.init

      view = Ansi.strip(form.view)
      view.should contain("First")
      view.should_not contain("Second")
    end

    it "stack layout shows all groups" do
      form = Huh.new_form(
        Huh.new_group(Huh.new_input.title("First")),
        Huh.new_group(Huh.new_input.title("Second")),
        Huh.new_group(Huh.new_input.title("Third"))
      ).with_layout(Huh::Layout::LAYOUT_STACK)
      form.init

      view = Ansi.strip(form.view)
      view.should contain("First")
      view.should contain("Second")
      view.should contain("Third")
    end

    it "columns layout shows current segment of groups" do
      form = Huh.new_form(
        Huh.new_group(Huh.new_input.title("First")),
        Huh.new_group(Huh.new_input.title("Second")),
        Huh.new_group(Huh.new_input.title("Third"))
      ).with_layout(Huh.layout_columns(2))
      form.init

      view = Ansi.strip(form.view)
      view.should contain("First")
      view.should contain("Second")
      view.should_not contain("Third")

      form, _ = form.update(Huh.next_group)
      form, _ = form.update(Huh.next_group)
      view = Ansi.strip(form.view)
      view.should contain("Third")
      view.should_not contain("First")
      view.should_not contain("Second")
    end

    it "grid layout shows current page of groups" do
      form = Huh.new_form(
        Huh.new_group(Huh.new_input.title("First")),
        Huh.new_group(Huh.new_input.title("Second")),
        Huh.new_group(Huh.new_input.title("Third")),
        Huh.new_group(Huh.new_input.title("Fourth")),
        Huh.new_group(Huh.new_input.title("Fifth"))
      ).with_layout(Huh.layout_grid(2, 2))
      form.init

      view = Ansi.strip(form.view)
      view.should contain("First")
      view.should contain("Second")
      view.should contain("Third")
      view.should contain("Fourth")
      view.should_not contain("Fifth")

      4.times do
        form, _ = form.update(Huh.next_group)
      end
      view = Ansi.strip(form.view)
      view.should contain("Fifth")
      view.should_not contain("First")
      view.should_not contain("Second")
      view.should_not contain("Third")
      view.should_not contain("Fourth")
    end
  end
end
