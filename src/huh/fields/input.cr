require "../field"
require "term2/components/text_input"

module Huh
  # Input field for single-line text entry
  class Input < Field(String)
    # Internal text input component from Term2
    @textinput : Term2::Components::TextInput

    # Field configuration
    property placeholder : String = ""
    property suggestions : Array(String) = [] of String
    property inline : Bool = false
    property validate : Proc(String, Exception | Nil)

    # Error state
    property error : Exception? = nil

    # Create a new Input field
    def initialize(value : String = "")
      super(value)

      # Initialize Term2 TextInput component
      @textinput = Term2::Components::TextInput.new

      # Set initial value
      @textinput.value = value

      # Default validation (always passes)
      @validate = Proc(String, Exception | Nil).new { nil }
    end

    # Required Field methods

    def init : Term2::Cmd
      # Initialize the text input component
      @textinput.init
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      # Delegate to text input component
      model, cmd = @textinput.update(msg)

      # Update our value from the text input
      @value = @textinput.value

      # Validate on change
      validate_field

      # Return updated model and command
      {self, cmd}
    end

    def view : String
      # Build the field view with title, description, and text input
      String.build do |str|
        # Title
        if !@title.empty?
          str << @title << "\n"
        end

        # Description
        if !@description.empty?
          str << @description << "\n"
        end

        # Error message
        if @error
          str << "Error: " << @error.not_nil!.message << "\n"
        end

        # Text input view
        str << @textinput.view
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
      writer << @title << ": " if !@title.empty?
      writer << @description << "\n" if !@description.empty?
      writer << "> "
      writer.flush

      input = reader.gets
      if input
        @value = input.chomp
        validate_field
      end
    end

    # Validation
    private def validate_field
      @error = @validate.call(@value.as(String))
    rescue e : Exception
      @error = e
    end

    # Fluent configuration methods

    def with_placeholder(placeholder : String) : self
      @placeholder = placeholder
      @textinput.placeholder = placeholder
      self
    end

    def with_char_limit(limit : Int32) : self
      @textinput.char_limit = limit
      self
    end

    def with_suggestions(suggestions : Array(String)) : self
      @suggestions = suggestions
      # TODO: Configure suggestions on textinput
      self
    end

    def with_inline(inline : Bool) : self
      @inline = inline
      self
    end

    def with_validate(&block : Proc(String, Exception | Nil)) : self
      @validate = block
      self
    end

    # Echo mode configuration
    enum EchoMode
      Normal
      Password
      None
    end

    def with_echo_mode(mode : EchoMode) : self
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
      with_echo_mode(EchoMode::Password)
    end

    # Prompt configuration
    def with_prompt(prompt : String) : self
      @textinput.prompt = prompt
      self
    end

    # Width configuration
    def with_width(width : Int32) : self
      @textinput.width = width
      super
    end

    # Height configuration
    def with_height(height : Int32) : self
      @textinput.height = height
      super
    end
  end
end
