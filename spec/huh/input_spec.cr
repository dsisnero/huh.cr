require "../spec_helper"
require "../../src/huh"
require "../golden_helper_spec"

module Huh
  describe Input do
    it "matches golden file for basic input" do
      # Create input field
      input = Huh.new_input

      # Create form with group (as done in golden generator)
      form = Huh.new_form(Huh.new_group(input))

      # Initialize the form
      form.update(form.init)

      # Get the view
      view = form.view

      # Compare with golden file
      GoldenHelper.assert_matches(view, "input_initial.txt")
    end

    it "matches golden file for input with title and description" do
      input = Huh.new_input
        .with_title("What's your name?")
        .with_description("Enter your full name")
        .with_placeholder("John Doe")

      form = Huh.new_form(Huh.new_group(input))
      form.update(form.init)
      view = form.view

      GoldenHelper.assert_matches(view, "input_with_title.txt")
    end
  end
end
