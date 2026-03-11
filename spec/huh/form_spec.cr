require "../spec_helper"
require "ansi"

module Huh
  class FooterErrorField < Field(String)
    property focused : Bool = false

    def initialize(@message : String)
      super("")
    end

    def field_keymap
      nil
    end

    def init : Tea::Cmd?
      nil
    end

    def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
      {self, nil}
    end

    def view : String
      "footer-error-field"
    end

    def blur : Tea::Cmd?
      @focused = false
      nil
    end

    def focus : Tea::Cmd?
      @focused = true
      nil
    end

    def error : Exception?
      Exception.new(@message)
    end

    def skip : Bool
      false
    end

    def zoom : Bool
      false
    end

    def key_binds : Array(KeyBinding)
      [] of KeyBinding
    end

    def run_accessible(writer : IO, reader : IO) : Nil
    end

    def focused? : Bool
      @focused
    end
  end

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

    it "propagates theme to groups including help styles" do
      form = Huh.new_form(Huh.new_group(Huh.new_input.title("Name")))
      theme = Huh.theme_catppuccin
      form.with_theme(theme)
      form.init

      group = form.selector.selected
      group.help.styles.short_key.foreground_color.should eq(theme.help.short_key.foreground_color)
    end

    it "renders group footer errors when enabled" do
      group = Huh.new_group(Huh::FooterErrorField.new("boom"))
      form = Huh.new_form(group).with_show_help(false).with_show_errors(true)
      form.init

      Ansi.strip(form.view).should contain("boom")
    end

    it "hides group footer errors when disabled" do
      group = Huh.new_group(Huh::FooterErrorField.new("boom"))
      form = Huh.new_form(group).with_show_help(false).with_show_errors(false)
      form.init

      Ansi.strip(form.view).should_not contain("boom")
    end
  end
end
