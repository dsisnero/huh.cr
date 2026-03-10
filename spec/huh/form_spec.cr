require "../spec_helper"

module Huh
  describe Form do
    it "skips hidden groups on init" do
      first = Huh.new_group(Huh.new_input.title("Hidden")).hide(true)
      second = Huh.new_group(Huh.new_input.title("Visible"))
      form = Huh.new_form(first, second)

      form.init

      form.selector.index.should eq(1)
      Ansi.strip(form.view).should contain("Visible")
      Ansi.strip(form.view).should_not contain("Hidden")
    end

    it "supports hiding groups dynamically with hide_func" do
      show_first = Huh.cell(true)
      first = Huh.new_group(Huh.new_input.title("First")).hide_func { !show_first.value }
      second = Huh.new_group(Huh.new_input.title("Second"))
      form = Huh.new_form(first, second)

      form.init
      form.selector.index.should eq(0)

      show_first.value = false
      form, _ = form.update(Tea.key('x'))

      form.selector.index.should eq(1)
      Ansi.strip(form.view).should contain("Second")
    end

    it "rejects timeout in accessible mode" do
      form = Huh.new_form(Huh.new_group(Huh.new_input.title("Name")))
        .with_accessible(true)
        .with_timeout(50.milliseconds)

      expect_raises(Huh::TimeoutUnsupportedError) do
        form.run
      end
    end
  end
end
