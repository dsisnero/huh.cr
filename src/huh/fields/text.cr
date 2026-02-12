require "../option"
require "../eval"
require "term2/components/text_area"

module Huh
  # Text is a text field for multi-line input.
  #
  # A text box is responsible for getting multi-line input from the user. Use
  # it to gather longer-form user input. The Text field can be filled with an
  # external editor.
  class Text < Field(String)
    # Internal accessor
    @accessor : Accessor(String)

    # Evaluatable fields
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @placeholder_eval : Eval(String)

    # Text area component
    @textarea : Term2::Components::TextArea

    # Validation
    @validate : Proc(String, Exception | Nil)
    @error : Exception? = nil

    # Field state
    @focused : Bool = false
    @external_editor : Bool = true
    @editor_cmd : String = "vim"
    @editor_args : Array(String) = [] of String
    @editor_extension : String = "md"
    @accessible : Bool = false
    @width : Int32 = 0
    @theme : Theme? = nil
    @keymap : KeyMap? = nil

    # Creates a new text field.
    def initialize
      # Initialize with default embedded accessor (empty string)
      @accessor = EmbeddedAccessor(String).new("")

      # Initialize eval objects
      @title_eval = Eval(String).new("")
      @description_eval = Eval(String).new("")
      @placeholder_eval = Eval(String).new("")

      # Initialize text area
      @textarea = Term2::Components::TextArea.new
      @textarea.show_line_numbers = false
      @textarea.prompt = ""

      # Default validation (always passes)
      @validate = Proc(String, Exception | Nil).new { nil }

      # Call parent initializer with initial value
      super(@accessor.get)
    end

    # Value sets the value of the text field using a cell
    def value(cell : Cell(String)) : self
      @accessor = PointerAccessor(String).new(cell)
      @value = @accessor.get
      @textarea.value = @value
      self
    end

    # Accessor sets the accessor of the text field
    def accessor(accessor : Accessor(String)) : self
      @accessor = accessor
      @value = @accessor.get
      @textarea.value = @value
      self
    end

    # Key sets the key of the text field which can be used to retrieve the value
    # after submission.
    def key(key : String) : self
      @key = key
      self
    end

    # Title sets the title of the text field.
    def title(title : String) : self
      @title_eval.value = title
      @title = title
      self
    end

    # TitleFunc sets the title func of the text field.
    def title_func(fn : Proc(String)) : self
      @title_eval.function = fn
      self
    end

    # Description sets the description of the text field.
    def description(description : String) : self
      @description_eval.value = description
      @description = description
      self
    end

    # DescriptionFunc sets the description func of the text field.
    def description_func(fn : Proc(String)) : self
      @description_eval.function = fn
      self
    end

    # Placeholder sets the placeholder of the text field.
    def placeholder(placeholder : String) : self
      @placeholder_eval.value = placeholder
      self
    end

    # PlaceholderFunc sets the placeholder func of the text field.
    def placeholder_func(fn : Proc(String)) : self
      @placeholder_eval.function = fn
      self
    end

    # ExternalEditor sets whether to use external editor.
    def external_editor(external : Bool) : self
      @external_editor = external
      self
    end

    # Editor sets the editor command and arguments.
    def editor(cmd : String, args : Array(String) = [] of String) : self
      @editor_cmd = cmd
      @editor_args = args
      self
    end

    # EditorExtension sets the file extension for temporary files.
    def editor_extension(ext : String) : self
      @editor_extension = ext
      self
    end

    # Height sets the height of the text field.
    def height(height : Int32) : self
      @textarea.height = height
      self
    end

    # Height property
    def height=(height : Int32)
      @textarea.height = height
    end

    # Width configuration
    def width(width : Int32) : self
      @width = width
      @textarea.width = width
      super
    end

    # Width property
    def width=(width : Int32)
      @width = width
      @textarea.width = width
    end

    # Validate sets the validation function of the text field.
    def validate(&block : Proc(String, Exception | Nil)) : self
      @validate = block
      self
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
      @textarea.init
    end

    def focused? : Bool
      @focused
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      # Delegate to text area component
      @textarea, cmd = @textarea.update(msg)

      # Update our value from the text area
      new_value = @textarea.value
      if new_value != @accessor.get
        @accessor.set(new_value)
        @value = new_value
        validate_field
      end

      {self, cmd}
    end

    def view : String
      # Build the field view with title, description, and text area
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

        # Text area
        str << @textarea.view.content
      end
    end

    def blur : Term2::Cmd
      value = @accessor.get
      @focused = false
      @error = @validate.call(value)
      Term2::Cmds.none
    end

    def focus : Term2::Cmd
      @focused = true
      @textarea.focus
      Term2::Cmds.none
    end

    def skip : Bool
      false
    end

    def zoom : Bool
      false
    end

    def error : Exception?
      @error
    end

    def key_binds : Array(KeyBinding)
      [] of KeyBinding
    end

    def run_accessible(writer : IO, reader : IO) : Nil
      # TODO: implement accessible mode
      writer << "Text field accessible mode not yet implemented\n"
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
