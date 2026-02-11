module Huh
  # Confirm field for yes/no boolean input
  class Confirm < Field(Bool)
    # Internal accessor
    @accessor : Accessor(Bool)

    # Field configuration
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @affirmative : String
    @negative : String

    # Field state
    property focused : Bool = false
    property validate : Proc(Bool, Exception | Nil)
    property error : Exception? = nil
    property accessible : Bool = false
    property width : Int32 = 0
    property height : Int32 = 0
    property theme : Theme? = nil
    property keymap : KeyMap? = nil
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

    # Value sets the value of the confirm field using a cell
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
      super
    end

    # Height configuration
    def height(height : Int32) : self
      @height = height
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
      Term2::Cmds.none
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      # TODO: Handle key events to toggle value
      {self, Term2::Cmds.none}
    end

    def view : String
      # Build the field view with title, description, and buttons
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

        # Simple button display (without styling for now)
        if @accessor.get
          str << "[#{@affirmative}] #{@negative}"
        else
          str << "#{@affirmative} [#{@negative}]"
        end
      end
    end

    def blur : Term2::Cmd
      @focused = false
      Term2::Cmds.none
    end

    def focus : Term2::Cmd
      @focused = true
      Term2::Cmds.none
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
      # Simple accessible mode: prompt and read yes/no
      title = @title_eval.value
      writer << title << ": " if !title.empty?
      description = @description_eval.value
      writer << description << "\n" if !description.empty?
      writer << "(#{@affirmative}/#{@negative}) > "
      writer.flush

      input = reader.gets
      if input
        normalized = input.strip.downcase
        if normalized == "y" || normalized == "yes" || normalized == @affirmative.downcase
          @accessor.set(true)
          @value = true
        elsif normalized == "n" || normalized == "no" || normalized == @negative.downcase
          @accessor.set(false)
          @value = false
        end
        validate_field
      end
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
