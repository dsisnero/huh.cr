module Huh
  # Base class for all form fields (type-erased)
  abstract class FieldBase
    include Term2::Model

    # Field configuration
    property title : String = ""
    property description : String = ""
    property key : String = ""
    property width : Int32 = 0
    property height : Int32 = 0
    property theme : Theme? = nil
    property key_map : KeyMap? = nil
    property accessible : Bool = false
    property position : FieldPosition? = nil

    # Value accessor (type-erased)
    abstract def value : Object
    abstract def value=(val : Object)

    # Required methods from Term2::Model
    abstract def init : Term2::Cmd
    abstract def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
    abstract def view : String

    # Field-specific methods
    abstract def blur : Term2::Cmd
    abstract def focus : Term2::Cmd
    abstract def error : Exception?
    abstract def skip : Bool
    abstract def zoom : Bool
    abstract def key_binds : Array(KeyBinding)
    abstract def run_accessible(writer : IO, reader : IO) : Nil
    abstract def focused? : Bool

    # Fluent configuration methods
    def with_title(title : String) : self
      @title = title
      self
    end

    def with_description(description : String) : self
      @description = description
      self
    end

    def with_key(key : String) : self
      @key = key
      self
    end

    def with_width(width : Int32) : self
      @width = width
      self
    end

    def with_height(height : Int32) : self
      @height = height
      self
    end

    def with_theme(theme : Theme) : self
      @theme = theme
      self
    end

    def with_key_map(key_map : KeyMap) : self
      @key_map = key_map
      self
    end

    def with_accessible(accessible : Bool) : self
      @accessible = accessible
      self
    end

    def with_position(position : FieldPosition) : self
      @position = position
      self
    end

    # Run the field as a standalone prompt
    def run : Nil
      # TODO: Implement standalone field execution
      raise "Not implemented yet"
    end

    # Get the field's key
    def get_key : String
      @key
    end

    # Get active styles based on focus state
    protected def active_styles : FieldStyles
      theme = @theme || Theme.default
      focused? ? theme.focused : theme.blurred
    end

    # Check if field is focused (to be implemented by subclasses)
    protected abstract def focused? : Bool
  end

  # Abstract base class for all form fields (typed)
  abstract class Field(T) < FieldBase
    # Typed value accessor
    property value : T

    def initialize(@value : T)
    end

    # Implement type-erased value accessors
    def value : Object
      @value
    end

    def value=(val : Object)
      @value = val.as(T)
    end

    # Typed getter
    def get_value : T
      @value
    end
  end

  # Field position information
  record FieldPosition,
    group : Int32,
    field : Int32,
    first_field : Bool,
    last_field : Bool

  # Key binding for help display
  record KeyBinding,
    action : Symbol,
    keys : Array(String),
    help : String = ""

  # Theme is defined in theme.cr
  # Key map (placeholder - will be implemented later)
  class KeyMap
  end
end
