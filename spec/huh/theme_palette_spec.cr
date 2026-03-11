require "../spec_helper"

module Huh
  describe Theme do
    it "ports ThemeDracula palette assignments" do
      theme = Huh.theme_dracula

      theme.focused.base.border_left_foreground_color.should_not be_nil
      theme.focused.focused_button.foreground_color.should_not be_nil
      theme.focused.focused_button.background_color.should_not be_nil
      theme.focused.text_input.prompt.foreground_color.should_not be_nil
    end

    it "ports ThemeBase16 palette assignments" do
      theme = Huh.theme_base16

      theme.focused.base.border_left_foreground_color.should_not be_nil
      theme.focused.title.foreground_color.should_not be_nil
      theme.focused.focused_button.background_color.should_not be_nil
      theme.blurred.text_input.prompt.foreground_color.should_not be_nil
    end

    it "ports ThemeCatppuccin palette assignments" do
      theme = Huh.theme_catppuccin

      theme.focused.title.foreground_color.should_not be_nil
      theme.focused.select_selector.foreground_color.should_not be_nil
      theme.focused.focused_button.background_color.should_not be_nil
      theme.focused.text_input.cursor.foreground_color.should_not be_nil
    end
  end
end
