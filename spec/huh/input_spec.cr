require "../spec_helper"
require "../../src/huh"
require "../golden_helper_spec"

module Huh
  describe Input do
    pending "matches golden file for basic input" do
      # Create input field
      input = Huh.new_input

      # Create form with group (as done in golden generator)
      form = Huh.new_form(Huh.new_group(input))

      # Initialize the form
      form.init

      # Get the view
      view = form.view

      # Compare with golden file
      GoldenHelper.assert_matches(view, "input_initial.txt")
    end

    pending "matches golden file for input with title and description" do
      input = Huh.new_input
        .title("What's your name?")
        .description("Enter your full name")
        .placeholder("John Doe")

      form = Huh.new_form(Huh.new_group(input))
      form.init
      view = form.view

      GoldenHelper.assert_matches(view, "input_with_title.txt")
    end

    it "can be created and configured" do
      input = Huh.new_input
        .title("Test")
        .description("Test description")
        .placeholder("Enter value")

      input.should be_a(Input)
    end
  end
end
