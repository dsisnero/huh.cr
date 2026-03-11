require "lipgloss"
require "bubbles"

module Huh
  # TextInputStyles are the styles for text inputs.
  class TextInputStyles
    property cursor : Lipgloss::Style
    property cursor_text : Lipgloss::Style
    property placeholder : Lipgloss::Style
    property prompt : Lipgloss::Style
    property text : Lipgloss::Style

    def initialize
      @cursor = Lipgloss::Style.new
      @cursor_text = Lipgloss::Style.new
      @placeholder = Lipgloss::Style.new
      @prompt = Lipgloss::Style.new
      @text = Lipgloss::Style.new
    end

    # Copy styles from another TextInputStyles
    def copy_from(other : TextInputStyles)
      @cursor = other.cursor
      @cursor_text = other.cursor_text
      @placeholder = other.placeholder
      @prompt = other.prompt
      @text = other.text
    end
  end

  # FieldStyles are the styles for input fields.
  class FieldStyles
    property base : Lipgloss::Style
    property title : Lipgloss::Style
    property description : Lipgloss::Style
    property error_indicator : Lipgloss::Style
    property error_message : Lipgloss::Style

    # Select styles.
    property select_selector : Lipgloss::Style # Selection indicator
    property option : Lipgloss::Style          # Select options
    property next_indicator : Lipgloss::Style
    property prev_indicator : Lipgloss::Style

    # FilePicker styles.
    property directory : Lipgloss::Style
    property file : Lipgloss::Style

    # Multi-select styles.
    property multiselect_selector : Lipgloss::Style
    property selected_option : Lipgloss::Style
    property selected_prefix : Lipgloss::Style
    property unselected_option : Lipgloss::Style
    property unselected_prefix : Lipgloss::Style

    # Textinput and textarea styles.
    property text_input : TextInputStyles

    # Confirm styles.
    property focused_button : Lipgloss::Style
    property blurred_button : Lipgloss::Style

    # Card styles.
    property card : Lipgloss::Style
    property note_title : Lipgloss::Style
    property next : Lipgloss::Style

    def initialize
      @base = Lipgloss::Style.new
      @title = Lipgloss::Style.new
      @description = Lipgloss::Style.new
      @error_indicator = Lipgloss::Style.new
      @error_message = Lipgloss::Style.new

      @select_selector = Lipgloss::Style.new
      @option = Lipgloss::Style.new
      @next_indicator = Lipgloss::Style.new
      @prev_indicator = Lipgloss::Style.new

      @directory = Lipgloss::Style.new
      @file = Lipgloss::Style.new

      @multiselect_selector = Lipgloss::Style.new
      @selected_option = Lipgloss::Style.new
      @selected_prefix = Lipgloss::Style.new
      @unselected_option = Lipgloss::Style.new
      @unselected_prefix = Lipgloss::Style.new

      @text_input = TextInputStyles.new

      @focused_button = Lipgloss::Style.new
      @blurred_button = Lipgloss::Style.new

      @card = Lipgloss::Style.new
      @note_title = Lipgloss::Style.new
      @next = Lipgloss::Style.new
    end

    # Copy styles from another FieldStyles
    def copy_from(other : FieldStyles)
      @base = other.base
      @title = other.title
      @description = other.description
      @error_indicator = other.error_indicator
      @error_message = other.error_message

      @select_selector = other.select_selector
      @option = other.option
      @next_indicator = other.next_indicator
      @prev_indicator = other.prev_indicator

      @directory = other.directory
      @file = other.file

      @multiselect_selector = other.multiselect_selector
      @selected_option = other.selected_option
      @selected_prefix = other.selected_prefix
      @unselected_option = other.unselected_option
      @unselected_prefix = other.unselected_prefix

      @text_input.copy_from(other.text_input)

      @focused_button = other.focused_button
      @blurred_button = other.blurred_button

      @card = other.card
      @note_title = other.note_title
      @next = other.next
    end
  end

  # FormStyles are the styles for a form.
  class FormStyles
    property base : Lipgloss::Style

    def initialize
      @base = Lipgloss::Style.new
    end
  end

  # GroupStyles are the styles for a group.
  class GroupStyles
    property base : Lipgloss::Style
    property title : Lipgloss::Style
    property description : Lipgloss::Style

    def initialize
      @base = Lipgloss::Style.new
      @title = Lipgloss::Style.new
      @description = Lipgloss::Style.new
    end
  end

  # Theme is a collection of styles for components of the form.
  # Themes can be applied to a form using the WithTheme option.
  class Theme
    property form : FormStyles
    property group : GroupStyles
    property field_separator : Lipgloss::Style
    property blurred : FieldStyles
    property focused : FieldStyles
    property help : Bubbles::Help::Styles

    def initialize
      @form = FormStyles.new
      @group = GroupStyles.new
      @field_separator = Lipgloss::Style.new
      @blurred = FieldStyles.new
      @focused = FieldStyles.new
      @help = Bubbles::Help.new.styles
    end

    # Create a new base theme with general styles to be inherited by other themes.
    def self.base : Theme
      theme = Theme.new

      # Default styles
      theme.form.base = Lipgloss::Style.new
      theme.group.base = Lipgloss::Style.new
      theme.field_separator = Lipgloss::Style.new.string=("\n\n")

      # Button style base
      button = Lipgloss::Style.new
        .padding(0, 2) # vertical=0, horizontal=2 like Go
        .margin_right(1)

      # Focused styles
      theme.focused.base = Lipgloss::Style.new
        .padding_left(1)
        .border_style(Lipgloss::Border.thick)
        .border_left(true)
      theme.focused.card = theme.focused.base
      theme.focused.focused_button = button
        .foreground(Lipgloss::Color.indexed(0))
        .background(Lipgloss::Color.indexed(7))
      theme.focused.blurred_button = button
        .foreground(Lipgloss::Color.indexed(7))
        .background(Lipgloss::Color.indexed(0))
      theme.focused.text_input.placeholder = Lipgloss::Style.new
        .foreground(Lipgloss::Color.indexed(8))
      theme.focused.error_indicator = Lipgloss::Style.new.string=(" *")
      theme.focused.error_message = Lipgloss::Style.new.string=(" *")
      theme.focused.select_selector = Lipgloss::Style.new.string=("> ")
      theme.focused.next_indicator = Lipgloss::Style.new.margin_left(1).string=("→")
      theme.focused.prev_indicator = Lipgloss::Style.new.margin_right(1).string=("←")
      theme.focused.multiselect_selector = Lipgloss::Style.new.string=("> ")
      theme.focused.selected_prefix = Lipgloss::Style.new.string=("[•] ")
      theme.focused.unselected_prefix = Lipgloss::Style.new.string=("[ ] ")

      # Blurred styles start as copy of focused
      theme.blurred.copy_from(theme.focused)
      # Copy and modify focused base for blurred base (matching Go pattern)
      theme.blurred.base = theme.focused.base
        .border_style(Lipgloss::Border.hidden)
      theme.blurred.card = theme.blurred.base
      theme.blurred.multiselect_selector = Lipgloss::Style.new.string=("  ")
      theme.blurred.next_indicator = Lipgloss::Style.new
      theme.blurred.prev_indicator = Lipgloss::Style.new

      # Group styles
      theme.group.title = theme.focused.title
      theme.group.description = theme.focused.description

      theme
    end

    # Returns a new theme based on the Charm color scheme.
    def self.charm : Theme
      theme = base

      # Colors matching Go implementation
      indigo = Lipgloss::Color.from_hex("#5A56E0")
      cream = Lipgloss::Color.from_hex("#FFFDF5")
      fuchsia = Lipgloss::Color.from_hex("#F780E2")
      green = Lipgloss::Color.from_hex("#02BA84")
      red = Lipgloss::Color.from_hex("#FF4672")

      # Focused styles
      theme.focused.base = theme.focused.base.border_foreground(Lipgloss::Color.indexed(238))
      theme.focused.card = theme.focused.base
      theme.focused.title = theme.focused.title.foreground(indigo).bold(true)
      theme.focused.note_title = theme.focused.note_title.foreground(indigo).bold(true).margin_bottom(1)
      theme.focused.directory = theme.focused.directory.foreground(indigo)
      theme.focused.error_indicator = theme.focused.error_indicator.foreground(red)
      theme.focused.error_message = theme.focused.error_message.foreground(red)
      theme.focused.select_selector = theme.focused.select_selector.foreground(fuchsia).string=("> ")
      theme.focused.next_indicator = theme.focused.next_indicator.foreground(fuchsia).string=("→")
      theme.focused.prev_indicator = theme.focused.prev_indicator.foreground(fuchsia).string=("←")
      theme.focused.multiselect_selector = theme.focused.multiselect_selector.foreground(fuchsia)
      theme.focused.selected_option = theme.focused.selected_option.foreground(green)
      theme.focused.selected_prefix = Lipgloss::Style.new.foreground(Lipgloss::Color.from_hex("#02CF92")).string=("✓ ")
      theme.focused.unselected_prefix = Lipgloss::Style.new.string=("• ")
      theme.focused.focused_button = theme.focused.focused_button.foreground(cream).background(fuchsia)
      theme.focused.next = theme.focused.focused_button
      theme.focused.blurred_button = theme.focused.blurred_button.foreground(Lipgloss::Color.indexed(235)).background(Lipgloss::Color.indexed(252))

      theme.focused.text_input.cursor = theme.focused.text_input.cursor.foreground(green)
      theme.focused.text_input.prompt = theme.focused.text_input.prompt.foreground(fuchsia)

      # Blurred styles
      theme.blurred.copy_from(theme.focused)
      # Copy and modify focused base for blurred base (matching Go pattern)
      theme.blurred.base = theme.focused.base
        .padding_left(1)
        .border_style(Lipgloss::Border.hidden)
        .border_left(true)
        .border_foreground(Lipgloss::Color.indexed(238))
      theme.blurred.card = theme.blurred.base
      theme.blurred.next_indicator = Lipgloss::Style.new
      theme.blurred.prev_indicator = Lipgloss::Style.new
      theme.blurred.multiselect_selector = Lipgloss::Style.new.string=("  ")

      theme.group.title = theme.focused.title
      theme.group.description = theme.focused.description

      theme
    end

    # Default theme (Charm)
    def self.default : Theme
      charm
    end

    # Returns a theme inspired by Dracula.
    def self.dracula : Theme
      theme = base

      background = Lipgloss::Color.from_hex("#282a36")
      selection = Lipgloss::Color.from_hex("#44475a")
      foreground = Lipgloss::Color.from_hex("#f8f8f2")
      comment = Lipgloss::Color.from_hex("#6272a4")
      green = Lipgloss::Color.from_hex("#50fa7b")
      purple = Lipgloss::Color.from_hex("#bd93f9")
      red = Lipgloss::Color.from_hex("#ff5555")
      yellow = Lipgloss::Color.from_hex("#f1fa8c")

      theme.focused.base = theme.focused.base.border_foreground(selection)
      theme.focused.card = theme.focused.base
      theme.focused.title = theme.focused.title.foreground(purple)
      theme.focused.note_title = theme.focused.note_title.foreground(purple)
      theme.focused.description = theme.focused.description.foreground(comment)
      theme.focused.error_indicator = theme.focused.error_indicator.foreground(red)
      theme.focused.directory = theme.focused.directory.foreground(purple)
      theme.focused.file = theme.focused.file.foreground(foreground)
      theme.focused.error_message = theme.focused.error_message.foreground(red)
      theme.focused.select_selector = theme.focused.select_selector.foreground(yellow)
      theme.focused.next_indicator = theme.focused.next_indicator.foreground(yellow)
      theme.focused.prev_indicator = theme.focused.prev_indicator.foreground(yellow)
      theme.focused.option = theme.focused.option.foreground(foreground)
      theme.focused.multiselect_selector = theme.focused.multiselect_selector.foreground(yellow)
      theme.focused.selected_option = theme.focused.selected_option.foreground(green)
      theme.focused.selected_prefix = theme.focused.selected_prefix.foreground(green)
      theme.focused.unselected_option = theme.focused.unselected_option.foreground(foreground)
      theme.focused.unselected_prefix = theme.focused.unselected_prefix.foreground(comment)
      theme.focused.focused_button = theme.focused.focused_button.foreground(yellow).background(purple).bold(true)
      theme.focused.blurred_button = theme.focused.blurred_button.foreground(foreground).background(background)
      theme.focused.text_input.cursor = theme.focused.text_input.cursor.foreground(yellow)
      theme.focused.text_input.placeholder = theme.focused.text_input.placeholder.foreground(comment)
      theme.focused.text_input.prompt = theme.focused.text_input.prompt.foreground(yellow)

      theme.blurred.copy_from(theme.focused)
      theme.blurred.base = theme.blurred.base.border_style(Lipgloss::Border.hidden)
      theme.blurred.card = theme.blurred.base
      theme.blurred.next_indicator = Lipgloss::Style.new
      theme.blurred.prev_indicator = Lipgloss::Style.new

      theme.group.title = theme.focused.title
      theme.group.description = theme.focused.description
      theme
    end

    # Returns a theme inspired by Base16.
    def self.base16 : Theme
      theme = base

      theme.focused.base = theme.focused.base.border_foreground(Lipgloss::Color.indexed(8))
      theme.focused.card = theme.focused.base
      theme.focused.title = theme.focused.title.foreground(Lipgloss::Color.indexed(6))
      theme.focused.note_title = theme.focused.note_title.foreground(Lipgloss::Color.indexed(6))
      theme.focused.directory = theme.focused.directory.foreground(Lipgloss::Color.indexed(6))
      theme.focused.description = theme.focused.description.foreground(Lipgloss::Color.indexed(8))
      theme.focused.error_indicator = theme.focused.error_indicator.foreground(Lipgloss::Color.indexed(9))
      theme.focused.error_message = theme.focused.error_message.foreground(Lipgloss::Color.indexed(9))
      theme.focused.select_selector = theme.focused.select_selector.foreground(Lipgloss::Color.indexed(3))
      theme.focused.next_indicator = theme.focused.next_indicator.foreground(Lipgloss::Color.indexed(3))
      theme.focused.prev_indicator = theme.focused.prev_indicator.foreground(Lipgloss::Color.indexed(3))
      theme.focused.option = theme.focused.option.foreground(Lipgloss::Color.indexed(7))
      theme.focused.multiselect_selector = theme.focused.multiselect_selector.foreground(Lipgloss::Color.indexed(3))
      theme.focused.selected_option = theme.focused.selected_option.foreground(Lipgloss::Color.indexed(2))
      theme.focused.selected_prefix = theme.focused.selected_prefix.foreground(Lipgloss::Color.indexed(2))
      theme.focused.unselected_option = theme.focused.unselected_option.foreground(Lipgloss::Color.indexed(7))
      theme.focused.focused_button = theme.focused.focused_button.foreground(Lipgloss::Color.indexed(7)).background(Lipgloss::Color.indexed(5))
      theme.focused.blurred_button = theme.focused.blurred_button.foreground(Lipgloss::Color.indexed(7)).background(Lipgloss::Color.indexed(0))

      # Match upstream behavior exactly: these calls are intentionally no-op assignments.
      theme.focused.text_input.cursor.foreground(Lipgloss::Color.indexed(5))
      theme.focused.text_input.placeholder.foreground(Lipgloss::Color.indexed(8))
      theme.focused.text_input.prompt.foreground(Lipgloss::Color.indexed(3))

      theme.blurred.copy_from(theme.focused)
      theme.blurred.base = theme.blurred.base.border_style(Lipgloss::Border.hidden)
      theme.blurred.card = theme.blurred.base
      theme.blurred.note_title = theme.blurred.note_title.foreground(Lipgloss::Color.indexed(8))
      theme.blurred.title = theme.blurred.note_title.foreground(Lipgloss::Color.indexed(8))
      theme.blurred.text_input.prompt = theme.blurred.text_input.prompt.foreground(Lipgloss::Color.indexed(8))
      theme.blurred.text_input.text = theme.blurred.text_input.text.foreground(Lipgloss::Color.indexed(7))
      theme.blurred.next_indicator = Lipgloss::Style.new
      theme.blurred.prev_indicator = Lipgloss::Style.new

      theme.group.title = theme.focused.title
      theme.group.description = theme.focused.description
      theme
    end

    # Returns a theme inspired by Catppuccin.
    def self.catppuccin : Theme
      theme = base

      base_color = adaptive("#eff1f5", "#1e1e2e")
      text = adaptive("#4c4f69", "#cdd6f4")
      subtext1 = adaptive("#5c5f77", "#bac2de")
      subtext0 = adaptive("#6c6f85", "#a6adc8")
      overlay1 = adaptive("#8c8fa1", "#7f849c")
      overlay0 = adaptive("#9ca0b0", "#6c7086")
      green = adaptive("#40a02b", "#a6e3a1")
      red = adaptive("#d20f39", "#f38ba8")
      pink = adaptive("#ea76cb", "#f5c2e7")
      mauve = adaptive("#8839ef", "#cba6f7")
      cursor = adaptive("#dc8a78", "#f5e0dc")

      theme.focused.base = theme.focused.base.border_foreground(subtext1)
      theme.focused.card = theme.focused.base
      theme.focused.title = theme.focused.title.foreground(mauve)
      theme.focused.note_title = theme.focused.note_title.foreground(mauve)
      theme.focused.directory = theme.focused.directory.foreground(mauve)
      theme.focused.description = theme.focused.description.foreground(subtext0)
      theme.focused.error_indicator = theme.focused.error_indicator.foreground(red)
      theme.focused.error_message = theme.focused.error_message.foreground(red)
      theme.focused.select_selector = theme.focused.select_selector.foreground(pink)
      theme.focused.next_indicator = theme.focused.next_indicator.foreground(pink)
      theme.focused.prev_indicator = theme.focused.prev_indicator.foreground(pink)
      theme.focused.option = theme.focused.option.foreground(text)
      theme.focused.multiselect_selector = theme.focused.multiselect_selector.foreground(pink)
      theme.focused.selected_option = theme.focused.selected_option.foreground(green)
      theme.focused.selected_prefix = theme.focused.selected_prefix.foreground(green)
      theme.focused.unselected_prefix = theme.focused.unselected_prefix.foreground(text)
      theme.focused.unselected_option = theme.focused.unselected_option.foreground(text)
      theme.focused.focused_button = theme.focused.focused_button.foreground(base_color).background(pink)
      theme.focused.blurred_button = theme.focused.blurred_button.foreground(text).background(base_color)
      theme.focused.text_input.cursor = theme.focused.text_input.cursor.foreground(cursor)
      theme.focused.text_input.placeholder = theme.focused.text_input.placeholder.foreground(overlay0)
      theme.focused.text_input.prompt = theme.focused.text_input.prompt.foreground(pink)

      theme.blurred.copy_from(theme.focused)
      theme.blurred.base = theme.blurred.base.border_style(Lipgloss::Border.hidden)
      theme.blurred.card = theme.blurred.base
      theme.blurred.next_indicator = Lipgloss::Style.new
      theme.blurred.prev_indicator = Lipgloss::Style.new

      theme.help.ellipsis = theme.help.ellipsis.foreground(subtext0)
      theme.help.short_key = theme.help.short_key.foreground(subtext0)
      theme.help.short_desc = theme.help.short_desc.foreground(overlay1)
      theme.help.short_separator = theme.help.short_separator.foreground(subtext0)
      theme.help.full_key = theme.help.full_key.foreground(subtext0)
      theme.help.full_desc = theme.help.full_desc.foreground(overlay1)
      theme.help.full_separator = theme.help.full_separator.foreground(subtext0)

      theme.group.title = theme.focused.title
      theme.group.description = theme.focused.description
      theme
    end

    private def self.adaptive(light_hex : String, dark_hex : String) : Lipgloss::AdaptiveColor
      Lipgloss::AdaptiveColor.new(
        Lipgloss::Color.from_hex(light_hex),
        Lipgloss::Color.from_hex(dark_hex)
      )
    end
  end
end
