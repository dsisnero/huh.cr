require "lipgloss"

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

    def initialize
      @form = FormStyles.new
      @group = GroupStyles.new
      @field_separator = Lipgloss::Style.new
      @blurred = FieldStyles.new
      @focused = FieldStyles.new
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
  end
end
