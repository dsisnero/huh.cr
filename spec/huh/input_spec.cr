require "../spec_helper"
require "ansi"

module Huh
  describe Input do
    it "matches golden file for basic input" do
      # Create input field
      input = Huh.new_input

      # Create form with group (as done in golden generator)
      form = Huh.new_form(Huh.new_group(input))

      # Initialize the form
      form.init

      # Get the view and strip ANSI codes like Go tests do
      view = Ansi.strip(form.view)

      # Compare with golden file
      Golden.require_equal("input_initial", view, "testdata/go")
    end

    it "matches golden file for input with title and description" do
      input = Huh.new_input
        .title("What's your name?")
        .description("Enter your full name")
        .placeholder("John Doe")

      form = Huh.new_form(Huh.new_group(input))
      form.init
      view = Ansi.strip(form.view)

      Golden.require_equal("input_with_title", view, "testdata/go")
    end

    it "can be created and configured" do
      input = Huh.new_input
        .title("Test")
        .description("Test description")
        .placeholder("Enter value")

      input.should be_a(Input)
    end

    it "enables suggestion help keybind when suggestions are present" do
      input = Huh.new_input.suggestions(["alpha", "beta"])
      binds = input.key_binds

      binds.any? { |bind| bind.action == :accept_suggestion }.should be_true
    end
  end
end
