require "../utils"
require "lipgloss"

module Huh
  # Note field for displaying information to the user
  class Note < Field(Nil)
    # Field configuration
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @next_label : String

    # Field state
    property? focused : Bool = false
    property? show_next_button : Bool = false
    property? skip : Bool = true
    property? accessible : Bool = false
    property width : Int32 = 0
    property height : Int32 = 0
    property theme : Theme? = nil
    property keymap : NoteKeyMap? = nil

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

    # TitleFunc sets a function to dynamically compute the title.
    def title_func(fn : Proc(String)) : self
      @title_eval.function(fn)
      self
    end

    # DescriptionFunc sets a function to dynamically compute the description.
    def description_func(fn : Proc(String)) : self
      @description_eval.function(fn)
      self
    end

    # Height sets the note field's height
    def height(height : Int32) : self
      @height = height
      self
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
      self
    end

    # Theme configuration
    def theme(theme : Theme) : self
      @theme = theme
      self
    end

    # Keymap configuration
    def keymap(keymap : KeyMap) : self
      @keymap = keymap.note
      self
    end

    # Implement field_keymap abstract method
    def field_keymap : Object?
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
      if msg.is_a?(Huh::UpdateFieldMsg)
        @title_eval.update
        @description_eval.update
      end

      # TODO: Handle key events for navigation
      {self, nil}
    end

    def view : String
      styles = active_styles
      max_width = @width - styles.card.horizontal_frame_size
      sb = String::Builder.new

      title = @title_eval.value
      if !title.empty?
        sb << styles.note_title.render(Huh.wrap(title, max_width))
      end

      description = @description_eval.value
      if !description.empty?
        sb << "\n"
        sb << Huh.wrap(render_markdown(description), max_width)
        sb << "\n"
      end

      if @show_next_button
        sb << "\n"
        sb << styles.next.render(@next_label)
      end

      styles.card
        .height(@height)
        .width(@width)
        .render(sb.to_s)
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
      @skip
    end

    def zoom : Bool
      false
    end

    def key_binds : Array(KeyBinding)
      [] of KeyBinding
    end

    def error : Exception?
      nil
    end

    def run_accessible(writer : IO, reader : IO) : Nil
      styles = active_styles
      title = @title_eval.value
      if !title.empty?
        writer << styles.title.render(title) << "\n"
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
      result = String::Builder.new
      italic = false
      bold = false
      codeblock = false
      escape = false

      input.each_char do |char|
        if escape || codeblock
          result << char
          escape = false
          next
        end

        case char
        when '\\'
          escape = true
        when '_'
          if !italic
            result << "\e[3m"
            italic = true
          else
            result << "\e[23m"
            italic = false
          end
        when '*'
          if !bold
            result << "\e[1m"
            bold = true
          else
            result << "\e[22m"
            bold = false
          end
        when '`'
          if !codeblock
            result << "\e[0;37;40m"
            result << " "
            codeblock = true
          else
            result << " "
            result << "\e[0m"
            codeblock = false

            if bold
              result << "\e[1m"
            end
            if italic
              result << "\e[3m"
            end
          end
        else
          result << char
        end
      end

      # Reset any open formatting
      result << "\e[0m"
      result.to_s
    end
  end
end
