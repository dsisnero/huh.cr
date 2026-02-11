require "term2/components/text_input"

module Huh
  # Input field for single-line text entry
  class Input < Field(String)
    # Internal accessor
    @accessor : Accessor(String)

    # Internal text input component from Term2
    @textinput : Term2::Components::TextInput

    # Field configuration with eval
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @placeholder_eval : Eval(String)
    @suggestions_eval : Eval(Array(String))

    # Field state
    property inline : Bool = false
    property validate : Proc(String, Exception | Nil)
    property error : Exception? = nil
    property accessible : Bool = false
    property width : Int32 = 0
    property height : Int32 = 0
    property theme : Theme? = nil
    property keymap : KeyMap? = nil

    # Create a new Input field
    def initialize
      # Initialize with empty string embedded accessor
      @accessor = EmbeddedAccessor(String).new("")

      # Initialize Term2 TextInput component
      @textinput = Term2::Components::TextInput.new
      @textinput.value = @accessor.get

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

    # Value sets the value of the input field using a cell
    def value(cell : Cell(String)) : self
      @accessor = PointerAccessor(String).new(cell)
      @textinput.value = @accessor.get
      self
    end

    # Accessor sets the accessor of the input field
    def accessor(accessor : Accessor(String)) : self
      @accessor = accessor
      @textinput.value = @accessor.get
      self
    end

    # Title sets the title of the input field
    def title(title : String) : self
      @title_eval.value = title
      self
    end

    # Description sets the description of the input field
    def description(description : String) : self
      @description_eval.value = description
      self
    end

    # Placeholder sets the placeholder of the input field
    def placeholder(placeholder : String) : self
      @placeholder_eval.value = placeholder
      @textinput.placeholder = placeholder
      self
    end

    # Suggestions sets the suggestions to display for autocomplete
    def suggestions(suggestions : Array(String)) : self
      @suggestions_eval.value = suggestions
      # TODO: Configure suggestions on textinput
      self
    end

    # CharLimit sets the character limit of the input field
    def char_limit(limit : Int32) : self
      @textinput.char_limit = limit
      self
    end

    # Echo mode configuration
    enum EchoMode
      Normal
      Password
      None
    end

    def echo_mode(mode : EchoMode) : self
      case mode
      when EchoMode::Normal
        @textinput.echo_mode = Term2::Components::TextInput::EchoMode::Normal
      when EchoMode::Password
        @textinput.echo_mode = Term2::Components::TextInput::EchoMode::Password
      when EchoMode::None
        @textinput.echo_mode = Term2::Components::TextInput::EchoMode::None
      end
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
      @textinput.width = width
      super
    end

    # Height configuration
    def height(height : Int32) : self
      @height = height
      @textinput.height = height
      super
    end

    # Theme configuration
    def theme(theme : Theme) : self
      @theme = theme
      self
    end

    # Keymap configuration
    def keymap(keymap : KeyMap) : self
      @keymap = keymap
      self
    end

    # Accessible mode configuration
    def accessible(accessible : Bool) : self
      @accessible = accessible
      self
    end

    # Required Field methods

    def init : Term2::Cmd
      @textinput.init
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      # Delegate to text input component
      _, cmd = @textinput.update(msg)

      # Update our value from the text input
      new_value = @textinput.value
      if new_value != @accessor.get
        @accessor.set(new_value)
        @value = new_value
        validate_field
      end

      {self, cmd}
    end

    def view : String
      # Build the field view with title, description, and text input
      String.build do |str|
        # Title
        title = @title_eval.value
        if !title.empty?
          str << title << "\n"
        end

        # Description
        description = @description_eval.value
        if !description.empty?
          str << description << "\n"
        end

        # Error message
        if @error
          str << "Error: " << @error.not_nil!.message << "\n"
        end

        # Text input view
        str << @textinput.view.content
      end
    end

    def blur : Term2::Cmd
      @textinput.blur
    end

    def focus : Term2::Cmd
      @textinput.focus
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
      # Simple accessible mode: prompt and read line
      title = @title_eval.value
      writer << title << ": " if !title.empty?
      description = @description_eval.value
      writer << description << "\n" if !description.empty?
      writer << "> "
      writer.flush

      input = reader.gets
      if input
        @accessor.set(input.chomp)
        @value = @accessor.get
        validate_field
      end
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
  end
end
