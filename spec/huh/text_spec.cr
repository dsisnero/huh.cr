require "../spec_helper"

module Huh
  describe Text do
    it "creates a new text field" do
      text = Huh.new_text
      text.should be_a(Text)
    end

    it "sets title" do
      text = Huh.new_text.title("Tell us about yourself")
      text.should be_a(Text)
    end

    it "sets description" do
      text = Huh.new_text.description("Write a short bio")
      text.should be_a(Text)
    end

    it "sets placeholder" do
      text = Huh.new_text.placeholder("Enter your story here...")
      text.should be_a(Text)
    end

    it "sets char limit" do
      text = Huh.new_text.char_limit(500)
      text.char_limit.should eq(500)
    end

    it "sets lines" do
      text = Huh.new_text.lines(5)
      text.lines.should eq(5)
    end

    it "sets show line numbers" do
      text = Huh.new_text.show_line_numbers(true)
      text.show_line_numbers?.should be_true
    end

    it "sets value with cell" do
      cell = Cell(String).new("Initial text")
      text = Huh.new_text.value(cell)
      text.get_value.should eq("Initial text")
    end

    it "validates with block" do
      cell = Cell(String).new("")
      text = Huh.new_text.value(cell).validate do |value|
        if value.size < 10
          Exception.new("Must be at least 10 characters")
        end
      end

      text.value = "Short"
      text.error.should be_a(Exception)
      text.error.not_nil!.message.should eq("Must be at least 10 characters")

      text.value = "This is a longer text that should pass validation"
      text.error.should be_nil
    end

    it "has key binds" do
      text = Huh.new_text
      binds = text.key_binds
      binds.should be_a(Array(Huh::KeyBinding))
      binds.size.should be > 0
    end

    it "can focus and blur" do
      text = Huh.new_text
      cmd = text.focus
      cmd.should be_a(Tea::Cmd?)
      text.focused?.should be_true

      cmd = text.blur
      cmd.should be_nil
      text.focused?.should be_false
    end

    it "renders view" do
      text = Huh.new_text.title("Test Text Field")
      view = text.view
      view.should be_a(String)
      view.should contain("Test Text Field")
    end

    it "sets external editor" do
      text = Huh.new_text.external_editor(true)
      text.should be_a(Text)
    end

    it "sets editor command" do
      text = Huh.new_text.editor("nano")
      text.should be_a(Text)
    end

    it "sets editor args" do
      text = Huh.new_text.editor("vim", ["+set number"])
      text.should be_a(Text)
    end

    it "sets editor extension" do
      text = Huh.new_text.editor_extension("txt")
      text.should be_a(Text)
    end
  end
end
