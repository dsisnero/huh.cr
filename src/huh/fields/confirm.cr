require "../utils"
require "lipgloss"
require "../accessibility"

module Huh
  # Confirm field for yes/no boolean input
  class Confirm < Field(Bool)
    # Internal accessor
    @accessor : Accessor(Bool)

    # Field configuration with eval
    @title_eval : Eval(String)
    @description_eval : Eval(String)

    # Field state
    property affirmative : String = "Yes"
    property negative : String = "No"
    property button_alignment : Lipgloss::Position = Lipgloss::Position::Left
    property validate : Proc(Bool, Exception | Nil)
    property error : Exception? = nil
    property? accessible : Bool = false
    property width : Int32 = 0
    property height : Int32 = 0
    property theme : Theme? = nil
    property keymap : ConfirmKeyMap? = nil
    property? focused : Bool = false
    property? inline : Bool = false
    property button_alignment : Lipgloss::Position = Lipgloss::Position::Left
    property affirmative : String
    property negative : String

    # Create a new Confirm field
    def initialize
      # Initialize with false embedded accessor
      @accessor = EmbeddedAccessor(Bool).new(false)

      # Initialize eval objects
      @title_eval = Eval(String).new("")
      @description_eval = Eval(String).new("")
      @affirmative = "Yes"
      @negative = "No"

      # Default validation (always passes)
      @validate = Proc(Bool, Exception | Nil).new { nil }

      # Call parent initializer with initial value
      super(@accessor.get)
    end

    # Value sets the value of the confirm field using a ref
    def value(cell : Cell(Bool)) : self
      @accessor = PointerAccessor(Bool).new(cell)
      self
    end

    # Accessor sets the accessor of the confirm field
    def accessor(accessor : Accessor(Bool)) : self
      @accessor = accessor
      self
    end

    # Title sets the title of the confirm field
    def title(title : String) : self
      @title_eval.value = title
      self
    end

    # Description sets the description of the confirm field
    def description(description : String) : self
      @description_eval.value = description
      self
    end

    # Affirmative sets the affirmative button text
    def affirmative(text : String) : self
      @affirmative = text
      self
    end

    # Negative sets the negative button text
    def negative(text : String) : self
      @negative = text
      self
    end

    # Validate configuration
    def validate(&block : Proc(Bool, Exception | Nil)) : self
      @validate = block
      self
    end

    # Width configuration
    def width(width : Int32) : self
      @width = width
      self
    end

    # Height configuration
    def height(height : Int32) : self
      @height = height
      self
    end

    # Theme configuration
    def theme(theme : Theme) : self
      @theme = theme
      self
    end

    # Keymap configuration
    def keymap(keymap : KeyMap) : self
      @keymap = keymap.confirm
      self
    end

    # Implement field_keymap abstract method
    def field_keymap
      @keymap
    end

    # Accessible mode configuration
    def accessible(accessible : Bool) : self
      @accessible = accessible
      self
    end

    # Required Field methods

    def init : Tea::Cmd?
      nil
    end

    def focused? : Bool
      @focused
    end

    def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
      cmds = [] of Tea::Cmd?

      case msg
      when Huh::UpdateFieldMsg
        @title_eval.update
        @description_eval.update
      when Tea::KeyPressMsg
        key_msg = msg.as(Tea::KeyPressMsg)
        @error = nil

        # Use default keymap if none is set
        keymap = @keymap || Huh::DEFAULT_KEYMAP.confirm

        # Update keymap enabled states based on position
        update_keymap_enabled

        if Bubbles::Key.matches?(key_msg, keymap.toggle)
          if !@negative.empty?
            @accessor.set(!@accessor.get)
            @value = @accessor.get
          end
        elsif Bubbles::Key.matches?(key_msg, keymap.prev)
          cmds << (-> : ::Tea::Msg? { Huh.prev_field })
        elsif Bubbles::Key.matches?(key_msg, keymap.next, keymap.submit)
          cmds << (-> : ::Tea::Msg? { Huh.next_field })
        elsif Bubbles::Key.matches?(key_msg, keymap.accept)
          @accessor.set(true)
          @value = @accessor.get
          cmds << (-> : ::Tea::Msg? { Huh.next_field })
        elsif Bubbles::Key.matches?(key_msg, keymap.reject)
          @accessor.set(false)
          @value = @accessor.get
          cmds << (-> : ::Tea::Msg? { Huh.next_field })
        end
      end

      {self, Tea.batch(cmds)}
    end

    # Update keymap enabled states based on field position
    private def update_keymap_enabled
      keymap = @keymap || Huh::DEFAULT_KEYMAP.confirm
      position = @position

      if position
        # Prev is enabled if not first field
        keymap.prev.set_enabled(!position.first_field)
        # Next is enabled if not last field
        keymap.next.set_enabled(!position.last_field)
        # Submit is enabled if last field
        keymap.submit.set_enabled(position.last_field)
      else
        # If no position info, enable all
        keymap.prev.set_enabled(true)
        keymap.next.set_enabled(true)
        keymap.submit.set_enabled(true)
      end

      # Toggle is enabled if there's a negative option
      keymap.toggle.set_enabled(!@negative.empty?)
      # Accept is always enabled
      keymap.accept.set_enabled(true)
      # Reject is enabled only if there's a negative option
      keymap.reject.set_enabled(!@negative.empty?)

      # Update help text based on affirmative/negative text
      if !@negative.empty?
        keymap.accept.set_help("y", @affirmative)
        keymap.reject.set_help("n", @negative)
      else
        keymap.accept.set_help("y", @affirmative)
      end
    end

    def view : String
      styles = active_styles
      max_width = @width - styles.base.horizontal_frame_size

      wrote_header = false
      sb = String::Builder.new

      # Title
      title = @title_eval.value
      if !title.empty?
        sb << styles.title.render(Huh.wrap(title, max_width))
        wrote_header = true
      end

      # Error indicator
      if @error
        sb << styles.error_indicator.render("")
        wrote_header = true
      end

      # Description
      description = @description_eval.value
      if !description.empty?
        rendered_desc = styles.description.render(Huh.wrap(description, max_width))
        if !@inline && (description != "")
          sb << "\n"
        end
        sb << rendered_desc
        wrote_header = true
      end

      # Add spacing if not inline and we wrote header
      if !@inline && wrote_header
        sb << "\n\n"
      end

      # Button rendering
      negative = ""
      affirmative = ""
      if !@negative.empty?
        if @accessor.get
          affirmative = styles.focused_button.render(@affirmative)
          negative = styles.blurred_button.render(@negative)
        else
          affirmative = styles.blurred_button.render(@affirmative)
          negative = styles.focused_button.render(@negative)
        end
      else
        affirmative = styles.focused_button.render(@affirmative)
      end

      buttons_row = Lipgloss.join_horizontal(Lipgloss::Position::Center, affirmative, negative)

      # Calculate widths for alignment
      content = sb.to_s
      prompt_width = Lipgloss::Text.width(content)
      buttons_width = Lipgloss::Text.width(buttons_row)
      render_width = {buttons_width, prompt_width}.max

      # Apply alignment style
      aligned_buttons = Lipgloss::Style.new.width(render_width).align(@button_alignment).render(buttons_row)
      content_with_buttons = content + aligned_buttons

      # Apply base style with width and height
      styles.base
        .width(@width)
        .height(@height)
        .render(content_with_buttons)
    end

    def blur : Tea::Cmd?
      @focused = false
      nil
    end

    def focus : Tea::Cmd?
      @focused = true
      nil
    end

    def skip : Bool
      false
    end

    def zoom : Bool
      false
    end

    def key_binds : Array(KeyBinding)
      # Use default keymap if none is set
      keymap = @keymap || Huh::DEFAULT_KEYMAP.confirm

      binds = [] of KeyBinding

      # Convert Bubbles::Key::Binding to Huh::KeyBinding
      # Go Huh Confirm.KeyBinds() returns Toggle, Prev, Submit, Next, Accept, Reject
      # The form's help rendering will filter out disabled bindings

      if keymap.toggle.enabled?
        help = keymap.toggle.help
        binds << KeyBinding.new(:toggle, keymap.toggle.keys || [] of String, help.desc)
      end

      if keymap.prev.enabled?
        help = keymap.prev.help
        binds << KeyBinding.new(:prev, keymap.prev.keys || [] of String, help.desc)
      end

      if keymap.next.enabled?
        help = keymap.next.help
        binds << KeyBinding.new(:next, keymap.next.keys || [] of String, help.desc)
      end

      if keymap.submit.enabled?
        help = keymap.submit.help
        binds << KeyBinding.new(:submit, keymap.submit.keys || [] of String, help.desc)
      end

      if keymap.accept.enabled?
        help = keymap.accept.help
        binds << KeyBinding.new(:accept, keymap.accept.keys || [] of String, help.desc)
      end

      if keymap.reject.enabled?
        help = keymap.reject.help
        binds << KeyBinding.new(:reject, keymap.reject.keys || [] of String, help.desc)
      end

      binds
    end

    def run_accessible(writer : IO, reader : IO) : Nil
      styles = active_styles
      writer << styles.title.render(@title_eval.value) << "\n\n"

      # Use accessibility module for prompting
      result = Accessibility.prompt_bool(writer, reader, "Choose [y/N]: ")

      @accessor.set(result)
      @value = result
      writer << styles.selected_option.render("Chose: " + (result ? @affirmative : @negative))
      writer << "\n"
    end

    # Get the current value from the accessor
    def get_value : Bool
      @accessor.get
    end

    # Validation
    private def validate_field
      @error = @validate.call(@accessor.get)
    rescue e : Exception
      @error = e
    end
  end
end
