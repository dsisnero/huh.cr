require "bubbles"
require "../utils"
require "lipgloss"

module Huh
  # Input field for single-line text entry.
  #
  # Used for gathering short text input from users, such as names, email addresses,
  # or other single-line responses.
  #
  # ## Example
  #
  # ```
  # name = ""
  #
  # Huh.new_input
  #   .title("What's your name?")
  #   .placeholder("John Doe")
  #   .value(pointerof(name))
  #   .validate do |value|
  #     if value.empty?
  #       Exception.new("Name cannot be empty")
  #     end
  #   end
  #   .run
  #
  # puts "Hello, #{name}!"
  # ```
  #
  # ## Features
  #
  # - **Placeholder text**: Shows hint text when field is empty
  # - **Validation**: Custom validation functions
  # - **Suggestions**: Auto-complete suggestions as user types
  # - **Password mode**: Hide input for sensitive data
  # - **Character limit**: Restrict maximum input length
  #
  class Input < Field(String)
    # Internal accessor
    @accessor : Accessor(String)

    # Internal text input component from Bubbles v2.0.0
    @textinput : Bubbles::TextInput::Model

    # Field configuration with eval
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @placeholder_eval : Eval(String)
    @suggestions_eval : Eval(Array(String))

    # Field state
    property? inline : Bool = false
    property validate : Proc(String, Exception | Nil)
    property error : Exception? = nil
    property? accessible : Bool = false
    property width : Int32 = 0
    property height : Int32 = 0
    property theme : Theme? = nil
    property keymap : InputKeyMap? = nil
    property? focused : Bool = false
    property? inline : Bool = false

    # Create a new Input field
    def initialize
      # Initialize with empty string embedded accessor
      @accessor = EmbeddedAccessor(String).new("")

      # Initialize Bubbles TextInput component v2.0.0
      @textinput = Bubbles::TextInput::Model.new
      @textinput.set_value(@accessor.get)

      # Initialize eval objects
      @title_eval = Eval(String).new("")
      @description_eval = Eval(String).new("")
      @placeholder_eval = Eval(String).new("")
      @suggestions_eval = Eval(Array(String)).new([] of String)

      # Default validation (always passes)
      @validate = Proc(String, Exception | Nil).new { nil }

      # Call parent initializer with initial value
      super(@accessor.get)
    end

    # Value sets the value of the input field using a ref
    def value(cell : Cell(String)) : self
      @accessor = PointerAccessor(String).new(cell)
      @textinput.set_value(@accessor.get)
      self
    end

    # Value sets the value of the input field using a pointer (Go-compatible API)
    def value(ptr : Pointer(String)) : self
      @accessor = ProcAccessor(String).new(
        -> { ptr.value },
        ->(val : String) { ptr.value = val }
      )
      @textinput.set_value(@accessor.get)
      self
    end

    # Accessor sets the accessor of the input field
    def accessor(accessor : Accessor(String)) : self
      @accessor = accessor
      @textinput.set_value(@accessor.get)
      self
    end

    # Title sets the title of the input field
    def title(title : String) : self
      @title_eval.value = title
      self
    end

    # TitleFunc sets a function to dynamically compute the title
    def title_func(&block : -> String) : self
      @title_eval = Eval(String).new(&block)
      self
    end

    # Description sets the description of the input field
    def description(description : String) : self
      @description_eval.value = description
      self
    end

    # DescriptionFunc sets a function to dynamically compute the description
    def description_func(&block : -> String) : self
      @description_eval = Eval(String).new(&block)
      self
    end

    # Placeholder sets the placeholder of the input field
    def placeholder(placeholder : String) : self
      @placeholder_eval.value = placeholder
      # Go only shows first character of placeholder in initial view
      # So we set only first char to match Go behavior
      if !placeholder.empty?
        @textinput.placeholder = placeholder[0].to_s
      else
        @textinput.placeholder = ""
      end
      self
    end

    # Suggestions sets the suggestions to display for autocomplete
    def suggestions(suggestions : Array(String)) : self
      @suggestions_eval.value = suggestions
      # TODO: Configure suggestions on textinput
      self
    end

    # CharLimit sets the character limit of the input input field
    def char_limit(limit : Int32) : self
      @textinput.char_limit = limit
      self
    end

    # Echo mode configuration
    # Use Bubbles EchoMode enum directly
    alias EchoMode = Bubbles::TextInput::EchoMode

    def echo_mode(mode : EchoMode) : self
      @textinput.echo_mode = mode
      self
    end

    # Password shortcut
    def password : self
      echo_mode(EchoMode::Password)
    end

    # Prompt configuration
    def prompt(prompt : String) : self
      @textinput.prompt = prompt
      self
    end

    # Inline configuration
    def inline(inline : Bool) : self
      @inline = inline
      self
    end

    # Validate configuration
    def validate(&block : Proc(String, Exception | Nil)) : self
      @validate = block
      self
    end

    # Width configuration
    def width(width : Int32) : self
      @width = width
      @textinput.set_width(width)
      self
    end

    # Height configuration
    def height(height : Int32) : self
      @height = height
      @textinput.set_height(height)
      self
    end

    # Override with_width to also set textinput width
    def with_width(width : Int32) : self
      super
      @textinput.set_width(width)
      self
    end

    # Override with_height to also set textinput height
    def with_height(height : Int32) : self
      super
      @textinput.set_height(height)
      self
    end

    # Theme configuration
    def theme(theme : Theme) : self
      @theme = theme
      self
    end

    # Keymap configuration
    def keymap(keymap : KeyMap) : self
      @keymap = keymap.input
      # Apply keymap to textinput component
      if km = @keymap
        @textinput.key_map.accept_suggestion = km.accept_suggestion
      end
      self
    end

    # WithKeyMap sets the keymap on an input field (Go-compatible API)
    def with_keymap(keymap : KeyMap) : self
      self.keymap(keymap)
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
      @textinput.init
    end

    def focused? : Bool
      @focused
    end

    def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
      if msg.is_a?(Huh::UpdateFieldMsg)
        @title_eval.update
        @description_eval.update
        if @placeholder_eval.update
          @textinput.placeholder = @placeholder_eval.value
        end
        if @suggestions_eval.update
          @textinput.set_suggestions(@suggestions_eval.value)
        end
        return {self, nil}
      end

      # Delegate to text input component
      _, cmd = @textinput.update(msg)

      # Update our value from the text input
      new_value = @textinput.value
      if new_value != @accessor.get
        @accessor.set(new_value)
        @value = new_value
        validate_field
      end

      # Update keymap enabled states based on position
      update_keymap_enabled

      {self, cmd}
    end

    # Update keymap enabled states based on field position
    private def update_keymap_enabled
      keymap = @keymap || Huh::DEFAULT_KEYMAP.input
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
    end

    def view : String
      styles = active_styles
      max_width = @width - styles.base.horizontal_frame_size

      # Apply styles to text input component
      apply_styles

      # Adjust text input size to its char limit if it fits in its width
      if @textinput.char_limit > 0
        new_width = {@textinput.char_limit, @textinput.width, max_width}.min
        new_width = {new_width, 0}.max
        @textinput.set_width(new_width)
      end

      # Build the field view
      sb = String::Builder.new

      # Title
      title = @title_eval.value
      if !title.empty?
        rendered_title = styles.title.render(Huh.wrap(title, max_width))
        sb << rendered_title
        unless @inline
          sb << "\n"
        end
      end

      # Description
      description = @description_eval.value
      if !description.empty?
        rendered_description = styles.description.render(Huh.wrap(description, max_width))
        sb << rendered_description
        unless @inline
          sb << "\n"
        end
      end

      # Error message (TODO: style with error_message style)
      if error = @error
        sb << "Error: " << (error.message || "Error") << "\n"
      end

      # Text input view
      sb << @textinput.view

      # Apply base style with width and height
      styles.base
        .width(@width)
        .height(@height)
        .render(sb.to_s)
    end

    def blur : Tea::Cmd?
      @focused = false
      @textinput.blur
      nil
    end

    def focus : Tea::Cmd?
      @focused = true
      @textinput.focus
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
      keymap = @keymap || Huh::DEFAULT_KEYMAP.input

      binds = [] of KeyBinding

      # Convert Bubbles::Key::Binding to Huh::KeyBinding
      # Go Huh Input.KeyBinds() returns Prev, Submit, Next (and AcceptSuggestion if suggestions shown)
      # We don't have suggestions implemented yet, so just return Prev, Submit, Next
      # The form's help rendering will filter out disabled bindings

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

      binds
    end

    def run_accessible(writer : IO, reader : IO) : Nil
      styles = active_styles
      writer << styles.title.render(@title_eval.value) << "\n\n"

      # Use accessibility module for prompting
      input = Accessibility.prompt_string(writer, reader, "Input: ", ->(s : String) do
        err = @validate.call(s)
        err ? err.message : nil
    rescue e : Exception
      e.message
      end)

      @accessor.set(input)
      @value = @accessor.get
      writer << styles.selected_option.render("Input: " + @value)
      writer << "\n"
    end

    # Get the current value from the accessor
    def get_value : String
      @accessor.get
    end

    # Validation
    private def validate_field
      @error = @validate.call(@accessor.get)
    rescue e : Exception
      @error = e
    end

    # Apply theme styles to the text input component
    private def apply_styles
      theme = @theme || Theme.default
      focused_styles = theme.focused
      blurred_styles = theme.blurred

      # Create Bubbles TextInput styles
      input_styles = Bubbles::TextInput::Styles.new

      # Map focused styles
      input_styles.focused.text = focused_styles.text_input.text
      input_styles.focused.placeholder = focused_styles.text_input.placeholder
      input_styles.focused.prompt = focused_styles.text_input.prompt
      input_styles.focused.suggestion = focused_styles.text_input.text # TODO: separate suggestion style?

      # Map blurred styles
      input_styles.blurred.text = blurred_styles.text_input.text
      input_styles.blurred.placeholder = blurred_styles.text_input.placeholder
      input_styles.blurred.prompt = blurred_styles.text_input.prompt
      input_styles.blurred.suggestion = blurred_styles.text_input.text

      # Map cursor style (use focused cursor style for both states)
      # Extract color from cursor style's foreground if possible
      cursor_style = focused_styles.text_input.cursor
      cursor_color = cursor_style.foreground_color # returns Lipgloss::Color?
      input_styles.cursor.color = cursor_color || Lipgloss.color("7")
      # Shape defaults to Block
      input_styles.cursor.shape = Tea::CursorStyle::Block
      # TODO: map cursor_text style to cursor text styling?

      @textinput.styles = input_styles
    end
  end
end
