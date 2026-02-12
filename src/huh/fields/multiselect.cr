require "../option"
require "../eval"
require "term2/components/viewport"
require "term2/components/spinner"
require "term2/components/text_input"

module Huh
  # MultiSelect is a multi-select field.
  #
  # A multi-select field is a field that allows the user to select multiple
  # options from a list. The options can be provided statically or dynamically
  # using Options or OptionsFunc. The options can be filtered using "/" and
  # navigation is done using j/k, up/down keys. Selection is toggled with space
  # or enter, and limits can be set on the number of selectable options.
  class MultiSelect(T) < Field(Array(T))
    # Internal accessor (stores array of values)
    @accessor : Accessor(Array(T))

    # Viewport for scrolling options
    @viewport : Term2::Components::Viewport

    # Evaluatable fields
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @options_eval : Eval(Array(Option(T)))

    # Filtered options based on filter input
    @filtered_options : Array(Option(T))

    # Validation
    @validate : Proc(Array(T), Exception | Nil)
    @error : Exception? = nil

    # Selection state
    @cursor : Int32 = 0
    @focused : Bool = false
    @filtering : Bool = false

    # Filter input component
    @filter : Term2::Components::TextInput
    @spinner : Term2::Components::Spinner

    # Configuration
    property filterable : Bool = true
    property limit : Int32 = 0
    property width : Int32 = 0
    property height : Int32 = 0
    property accessible : Bool = false
    property theme : Theme? = nil
    property keymap : KeyMap? = nil

    MIN_HEIGHT     =  1
    DEFAULT_HEIGHT = 10

    # Error getter
    def error : Exception?
      @error
    end

    # Value getter (returns current value from accessor)
    def get_value : Array(T)
      @accessor.get
    end

    # Creates a new multi-select field.
    def initialize
      # Initialize with default embedded accessor (empty array)
      @accessor = EmbeddedAccessor(Array(T)).new([] of T)

      # Initialize viewport
      @viewport = Term2::Components::Viewport.new(0, 0)

      # Initialize eval objects
      @title_eval = Eval(String).new("")
      @description_eval = Eval(String).new("")
      @options_eval = Eval(Array(Option(T))).new([] of Option(T))
      @filtered_options = [] of Option(T)

      # Initialize filter input
      @filter = Term2::Components::TextInput.new
      @filter.prompt = "/"

      # Initialize spinner
      @spinner = Term2::Components::Spinner.new

      # Default validation (always passes)
      @validate = Proc(Array(T), Exception | Nil).new { nil }

      # Call parent initializer with initial value
      super(@accessor.get)
    end

    # Value sets the value of the multi-select field using a cell
    def value(cell : Cell(Array(T))) : self
      @accessor = PointerAccessor(Array(T)).new(cell)
      @value = @accessor.get
      select_options(@accessor.get)
      self
    end

    # Accessor sets the accessor of the multi-select field
    def accessor(accessor : Accessor(Array(T))) : self
      @accessor = accessor
      @value = @accessor.get
      select_options(@accessor.get)
      self
    end

    # Key sets the key of the multi-select field which can be used to retrieve the value
    # after submission.
    def key(key : String) : self
      @key = key
      self
    end

    # Title sets the title of the multi-select field.
    def title(title : String) : self
      @title_eval.value = title
      @title = title
      self
    end

    # TitleFunc sets the title func of the multi-select field.
    def title_func(fn : Proc(String)) : self
      @title_eval.function = fn
      self
    end

    # Description sets the description of the multi-select field.
    def description(description : String) : self
      @description_eval.value = description
      @description = description
      self
    end

    # DescriptionFunc sets the description func of the multi-select field.
    def description_func(fn : Proc(String)) : self
      @description_eval.function = fn
      self
    end

    # Options sets the options of the multi-select field.
    def options(options : Array(Option(T))) : self
      if options.empty?
        return self
      end
      @options_eval.value = options
      @filtered_options = options
      select_options(@accessor.get)
      update_viewport_height
      update_value
      self
    end

    # Options sets the options of the multi-select field using varargs.
    def options(*options : Option(T)) : self
      self.options(options.to_a)
    end

    # OptionsFunc sets the options func of the multi-select field.
    def options_func(fn : Proc(Array(Option(T)))) : self
      @options_eval.function = fn
      # If there is no height set, we should attach a static height since these
      # options are possibly dynamic.
      if @height <= 0
        @height = DEFAULT_HEIGHT
        update_viewport_height
      end
      self
    end

    # Filtering sets the filtering state of the multi-select field.
    def filtering(filtering : Bool) : self
      @filtering = filtering
      @filter.focus if filtering
      self
    end

    # Filterable sets whether the multi-select field is filterable.
    def filterable(filterable : Bool) : self
      @filterable = filterable
      self
    end

    # Limit sets the limit of selectable options (0 for no limit).
    def limit(limit : Int32) : self
      @limit = limit
      self
    end

    # Height sets the height of the multi-select field (chaining method).
    def height(height : Int32) : self
      @height = height
      update_viewport_height
      self
    end

    # Height setter (property)
    def height=(height : Int32)
      @height = height
      update_viewport_height
    end

    # Validate sets the validation function of the multi-select field.
    def validate(&block : Proc(Array(T), Exception | Nil)) : self
      @validate = block
      self
    end

    # Width configuration (chaining method)
    def width(width : Int32) : self
      @width = width
      @viewport.width = width
      super
    end

    # Width setter (property)
    def width=(width : Int32)
      @width = width
      @viewport.width = width
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
      @filter.init
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      cmd = Term2::Cmds.none

      if @filtering
        # Delegate to filter input
        @filter, cmd = @filter.update(msg)
        # Update filtered options based on filter value
        update_filtered_options

        # Check for escape to stop filtering
        case msg
        when Term2::Key
          case msg.key
          when "esc"
            stop_filtering
          end
        end
        return {self, cmd}
      end

      case msg
      when Term2::Key
        key = msg.key
        case key
        when "up", "k"
          move_cursor(-1)
        when "down", "j"
          move_cursor(1)
        when "space", "enter"
          toggle_selection
        when "/"
          start_filtering if @filterable
        when "esc"
          clear_filter
        when "ctrl+a"
          toggle_select_all if @limit <= 0
        end
      end

      {self, cmd}
    end

    def view : String
      update_viewport_height
      options = options_view
      @viewport.content = options

      parts = [] of String
      title = title_view
      parts << title unless title.empty?
      description = description_view
      parts << description unless description.empty?
      parts << @viewport.view.content
      parts.join("\n")
    end

    def blur : Term2::Cmd
      value = @accessor.get
      clear_filter
      @focused = false
      @error = @validate.call(value)
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
      # TODO: implement accessible mode
      writer << "MultiSelect field accessible mode not yet implemented\n"
    end

    # Private methods

    private def select_options(values : Array(T))
      # Mark options as selected based on current values
      @options_eval.value.each do |option|
        option.selected = values.includes?(option.value)
      end
      # Set cursor to first selected option or 0
      @options_eval.value.each_with_index do |option, i|
        if option.selected
          @cursor = i
          break
        end
      end
      @viewport.y_offset = @cursor
    end

    private def update_value
      selected_values = [] of T
      @options_eval.value.each do |option|
        if option.selected
          selected_values << option.value
        end
      end
      @accessor.set(selected_values)
      @value = selected_values
      @error = @validate.call(selected_values)
    end

    private def update_viewport_height
      # If no height is set size the viewport to the number of options.
      if @height <= 0
        # TODO: calculate height from options view
        @viewport.height = DEFAULT_HEIGHT
        return
      end

      # TODO: offset for title and description lines
      offset = 0

      @viewport.height = Math.max(MIN_HEIGHT, @height - offset)
      @viewport.y_offset = @cursor
    end

    private def clear_filter
      @filter.value = ""
      @filtered_options = @options_eval.value
      set_filtering(false)
    end

    private def set_filtering(filtering : Bool)
      @filtering = filtering
      # TODO: update keymap enabled states
    end

    private def title_view : String
      title = if @filtering
                @filter.view.content
              elsif !@filter.value.empty?
                "/" + @filter.value
              else
                @title_eval.value
              end
      if @error
        title + " [!]"
      else
        title
      end
    end

    private def description_view : String
      @description_eval.value
    end

    private def options_view : String
      sb = String::Builder.new
      @filtered_options.each_with_index do |option, i|
        cursor = @cursor == i
        selected = option.selected
        sb << render_option(option, cursor, selected)
        sb << "\n" if i < @filtered_options.size - 1
      end
      sb.to_s
    end

    private def render_option(option : Option(T), cursor : Bool, selected : Bool) : String
      if cursor
        prefix = "> "
      else
        prefix = "  "
      end
      if selected
        prefix + "[x] " + option.key
      else
        prefix + "[ ] " + option.key
      end
    end

    private def move_cursor(delta : Int32)
      new_index = @cursor + delta
      if new_index >= 0 && new_index < @filtered_options.size
        @cursor = new_index
        # Adjust viewport to keep cursor visible
        ensure_cursor_visible
      end
    end

    private def toggle_selection
      return if @filtered_options.empty?

      option = @filtered_options[@cursor]
      # Check limit constraint
      if !option.selected && @limit > 0 && num_selected >= @limit
        return
      end

      # Toggle selection in both filtered and original options
      option.selected = !option.selected
      # Also update the original option
      @options_eval.value.each_with_index do |orig_option, i|
        if orig_option.key == option.key
          @options_eval.value[i].selected = option.selected
          break
        end
      end

      update_value
    end

    private def start_filtering
      @filtering = true
      @filter.focus
    end

    private def stop_filtering
      @filtering = false
      @filter.blur
    end

    private def update_filtered_options
      filter_text = @filter.value.downcase
      if filter_text.empty?
        @filtered_options = @options_eval.value
      else
        @filtered_options = @options_eval.value.select do |option|
          option.key.downcase.includes?(filter_text)
        end
      end
      # Ensure cursor index stays within bounds
      @cursor = @cursor.clamp(0, Math.max(0, @filtered_options.size - 1))
    end

    private def ensure_cursor_visible
      # TODO: adjust viewport y_offset to keep cursor option visible
    end

    private def num_filtered_selected : Int32
      count = 0
      @filtered_options.each do |option|
        count += 1 if option.selected
      end
      count
    end

    private def toggle_select_all
      # Only allowed when limit <= 0 (no limit)
      return if @limit > 0

      any_unselected = false
      @filtered_options.each do |option|
        if !option.selected
          any_unselected = true
          break
        end
      end

      # If any unselected, select all; otherwise deselect all
      should_select = any_unselected
      @filtered_options.each do |option|
        option.selected = should_select
      end
      # Also update original options (they are same objects)
      update_value
    end

    private def num_selected : Int32
      count = 0
      @options_eval.value.each do |option|
        count += 1 if option.selected
      end
      count
    end
  end
end
