module Huh
  # Note field for displaying information to the user
  class Note < Field(Nil)
    # Field configuration
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @next_label : String

    # Field state
    property focused : Bool = false
    property show_next_button : Bool = false
    property skip : Bool = true
    property accessible : Bool = false
    property width : Int32 = 0
    property height : Int32 = 0
    property theme : Theme? = nil
    property keymap : KeyMap? = nil

    # Create a new Note field
    def initialize
      # Note has no value
      super(nil)

      # Initialize eval objects
      @title_eval = Eval(String).new("")
      @description_eval = Eval(String).new("")
      @next_label = "Next"
    end

    # Title sets the note field's title
    def title(title : String) : self
      @title_eval.value = title
      self
    end

    # Description sets the note field's description
    def description(description : String) : self
      @description_eval.value = description
      self
    end

    # Height sets the note field's height
    def height(height : Int32) : self
      @height = height
      super
    end

    # Next sets whether or not to show the next button
    def next(show : Bool) : self
      @show_next_button = show
      self
    end

    # NextLabel sets the next button label
    def next_label(label : String) : self
      @next_label = label
      self
    end

    # Width configuration
    def width(width : Int32) : self
      @width = width
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
      # TODO: Handle key events for navigation
      # TODO: Handle updateFieldMsg for dynamic content
      {self, Term2::Cmds.none}
    end

    def view : String
      # Build the note view with title and description
      String.build do |str|
        title = @title_eval.value
        if !title.empty?
          str << title << "\n"
        end

        description = @description_eval.value
        if !description.empty?
          str << description << "\n"
        end

        if @show_next_button
          str << "\n[#{@next_label}]"
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
      @skip
    end

    def zoom : Bool
      false
    end

    def key_binds : Array(KeyBinding)
      [] of KeyBinding
    end

    def run_accessible(writer : IO, reader : IO) : Nil
      title = @title_eval.value
      if !title.empty?
        writer << title << "\n"
      end
      description = @description_eval.value
      if !description.empty?
        writer << description << "\n"
      end
    end

    # Note has no value
    def get_value : Nil
      nil
    end

    # Simple markdown-like rendering (basic implementation)
    private def render_markdown(input : String) : String
      # TODO: Implement markdown rendering like Go version
      input
    end
  end
end
