require "../spec_helper"
require "../../src/huh"

module Huh
  describe Confirm do
    it "can be created and configured" do
      confirm = Huh.new_confirm
        .title("Agree to terms?")
        .description("Please read the terms carefully")
        .affirmative("I agree")
        .negative("I disagree")

      confirm.should be_a(Confirm)
    end

    it "has default values" do
      confirm = Huh.new_confirm
      confirm.get_value.should be_false
      confirm.affirmative("Yes").affirmative.should eq("Yes")
      confirm.negative("No").negative.should eq("No")
    end

    it "can set value via cell" do
      cell = Cell(Bool).new(true)
      confirm = Huh.new_confirm.value(cell)
      confirm.get_value.should be_true

      cell.value = false
      confirm.get_value.should be_false
    end

    it "matches golden file for basic confirm" do
      # Create confirm field with same options as golden file
      confirm_field = Huh.new_confirm
        .title("Are you sure?")
        .affirmative("Yes")
        .negative("No")

      # Create form with group (as done in golden generator)
      form = Huh.new_form(Huh.new_group(confirm_field))

      # Initialize the form
      form.init

      # Get the view and strip ANSI codes like Go tests do
      view = Ansi.strip(form.view)

      # Compare with golden file
      Golden.require_equal("confirm_initial", view, "testdata/go")
    end
  end
end
