require "../option"
require "../eval"
require "../utils"
require "term2/components/viewport"
require "term2/components/spinner"
require "term2/components/text_input"
require "lipgloss"

module Huh
  # Select is a select field.
  #
  # A select field is a field that allows the user to select from a list of
  # options. The options can be provided statically or dynamically using Options
  # or OptionsFunc. The options can be filtered using "/" and navigation is done
  # using j/k, up/down, or ctrl+n/ctrl+p keys.
  class Select(T) < Field(T)
    # Internal accessor
    @accessor : Accessor(T)

    # Viewport for scrolling options
    @viewport : Term2::Components::Viewport

    # Evaluatable fields
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @options_eval : Eval(Array(Option(T)))

    # Filtered options based on filter input
    @filtered_options : Array(Option(T))

    # Validation
    @validate : Proc(T, Exception | Nil)
    @error : Exception? = nil

    # Selection state
    @selected : Int32 = 0
    @focused : Bool = false
    @filtering : Bool = false

    # Filter input component
    @filter : Term2::Components::TextInput
    @spinner : Term2::Components::Spinner

    # Configuration
    property inline : Bool = false
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
    def get_value : T
      @accessor.get
    end

    # Creates a new select field.
    def initialize
      # Initialize with default embedded accessor (zero value)
      @accessor = EmbeddedAccessor(T).new(T.new)

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
      @validate = Proc(T, Exception | Nil).new { nil }

      # Call parent initializer with initial value
      super(@accessor.get)
    end

    # Value sets the value of the select field using a cell
    def value(cell : Cell(T)) : self
      @accessor = PointerAccessor(T).new(cell)
      @value = @accessor.get
      select_value(@accessor.get)
      update_value
      self
    end

    # Accessor sets the accessor of the select field
    def accessor(accessor : Accessor(T)) : self
      @accessor = accessor
      @value = @accessor.get
      select_value(@accessor.get)
      update_value
      self
    end

    # Key sets the key of the select field which can be used to retrieve the value
    # after submission.
    def key(key : String) : self
      @key = key
      self
    end

    # Title sets the title of the select field.
    def title(title : String) : self
      @title_eval.value = title
      @title = title
      self
    end

    # TitleFunc sets the title func of the select field.
    def title_func(fn : Proc(String)) : self
      @title_eval.function = fn
      self
    end

    # Description sets the description of the select field.
    def description(description : String) : self
      @description_eval.value = description
      @description = description
      self
    end

    # DescriptionFunc sets the description func of the select field.
    def description_func(fn : Proc(String)) : self
      @description_eval.function = fn
      self
    end

    # Options sets the options of the select field.
    def options(options : Array(Option(T))) : self
      if options.empty?
        return self
      end
      @options_eval.value = options
      @filtered_options = options
      select_option
      update_viewport_height
      update_value
      self
    end

    # Options sets the options of the select field using varargs.
    def options(*options : Option(T)) : self
      self.options(options.to_a)
    end

    # OptionsFunc sets the options func of the select field.
    def options_func(fn : Proc(Array(Option(T)))) : self
      @options_eval.function = fn
      # If there is no height set, we should attach a static height since these
      # options are possibly dynamic.
      if @height <= 0
        @height = 10
        update_viewport_height
      end
      self
    end

    # Filtering sets the filtering state of the select field.
    def filtering(filtering : Bool) : self
      @filtering = filtering
      @filter.focus if filtering
      self
    end

    # Inline sets whether the select input should be inline.
    def inline(inline : Bool) : self
      @inline = inline
      if inline
        height(1)
      end
      # TODO: enable/disable keymap left/right, up/down
      self
    end

    # Height sets the height of the select field (chaining method).
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

    # Validate sets the validation function of the select field.
    def validate(&block : Proc(T, Exception | Nil)) : self
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

    def focused? : Bool
      @focused
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
          move_selection(-1) unless @inline
        when "down", "j"
          move_selection(1) unless @inline
        when "left", "h"
          move_selection(-1) if @inline
        when "right", "l"
          move_selection(1) if @inline
        when "/"
          start_filtering
        when "enter"
          submit_selection
        when "esc"
          clear_filter
        end
      end

      {self, cmd}
    end

    def view : String
      styles = active_styles
      update_viewport_height
      vpc = options_view
      @viewport.content = vpc

      parts = [] of String
      title = title_view
      parts << title unless title.empty?
      description = description_view
      parts << description unless description.empty?
      parts << @viewport.view.content

      styles.base
        .width(@width)
        .height(@height)
        .render(parts.join("\n"))
    end

    def blur : Term2::Cmd
      value = @accessor.get
      if @inline
        clear_filter
        select_value(value)
      end
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
      writer << "Select field accessible mode not yet implemented\n"
    end

    # Private methods

    private def select_value(value : T)
      @options_eval.value.each_with_index do |option, i|
        if option.value == value
          @selected = i
          break
        end
      end
    end

    private def select_option
      # Set the cursor to the existing value or the last selected option.
      @options_eval.value.each_with_index do |option, i|
        if option.value == @accessor.get
          @selected = i
          break
        end
        if option.selected
          @selected = i
          break
        end
      end
      @viewport.y_offset = @selected
    end

    private def update_value
      if @selected >= 0 && @selected < @filtered_options.size
        @accessor.set(@filtered_options[@selected].value)
        @value = @accessor.get
      end
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
      @viewport.y_offset = @selected
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
      styles = active_styles
      max_width = @width - styles.base.horizontal_frame_size
      sb = String::Builder.new

      if @filtering
        # Apply styles to filter text input
        apply_filter_styles
        sb << @filter.view.content
      elsif !@filter.value.empty? && !@inline
        sb << styles.description.render("/" + @filter.value)
      else
        sb << styles.title.render(Huh.wrap(@title_eval.value, max_width))
      end

      if @error
        sb << styles.error_indicator.render("")
      end

      sb.to_s
    end

    # Apply theme styles to the filter text input component
    private def apply_filter_styles
      theme = @theme || Theme.default
      focused_styles = theme.focused
      blurred_styles = theme.blurred
      input_styles = Term2::Components::TextInput::Styles.new

      # Map focused styles
      input_styles.focused.text = focused_styles.text_input.text
      input_styles.focused.placeholder = focused_styles.text_input.placeholder
      input_styles.focused.prompt = focused_styles.text_input.prompt
      input_styles.focused.suggestion = focused_styles.text_input.text

      # Map blurred styles
      input_styles.blurred.text = blurred_styles.text_input.text
      input_styles.blurred.placeholder = blurred_styles.text_input.placeholder
      input_styles.blurred.prompt = blurred_styles.text_input.prompt
      input_styles.blurred.suggestion = blurred_styles.text_input.text

      # Map cursor style
      cursor_style = focused_styles.text_input.cursor
      cursor_color = cursor_style.foreground
      input_styles.cursor.color = cursor_color
      input_styles.cursor.shape = Term2::CursorShape::Block

      @filter.styles = input_styles
    end

    private def description_view : String
      return "" if @description_eval.value.empty?
      styles = active_styles
      max_width = @width - styles.base.horizontal_frame_size
      styles.description.render(Huh.wrap(@description_eval.value, max_width))
    end

    private def options_view : String
      if @inline
        return inline_options_view
      end

      sb = String::Builder.new
      @filtered_options.each_with_index do |option, i|
        selected = @selected == i
        sb << render_option(option, selected)
        sb << "\n" if i < @filtered_options.size - 1
      end
      sb.to_s
    end

    private def inline_options_view : String
      styles = active_styles
      option = if @filtered_options.empty?
                 styles.text_input.placeholder.render("No matches")
               else
                 styles.selected_option.render(@filtered_options[@selected].key)
               end

      # Get indicator strings (styled)
      prev_indicator = styles.prev_indicator.render("")
      next_indicator = styles.next_indicator.render("")

      Lipgloss::Style.new
        .width(@width)
        .render(Lipgloss.join_horizontal(Lipgloss::Position::Left,
          prev_indicator,
          option,
          next_indicator
        ))
    end

    private def render_option(option : Option(T), selected : Bool) : String
      styles = active_styles
      cursor = styles.select_selector.render("") # Get styled cursor (string value is in style)
      cursor_width = Lipgloss::Text.width(cursor)
      max_width = @width - styles.base.horizontal_frame_size - cursor_width

      key = Huh.wrap(option.key, max_width)

      if selected
        Lipgloss.join_horizontal(Lipgloss::Position::Left,
          cursor,
          styles.selected_option.render(key)
        )
      else
        Lipgloss.join_horizontal(Lipgloss::Position::Left,
          " " * cursor_width,
          styles.unselected_option.render(key)
        )
      end
    end

    private def move_selection(delta : Int32)
      new_index = @selected + delta
      if new_index >= 0 && new_index < @filtered_options.size
        @selected = new_index
        update_value
        # Adjust viewport to keep selection visible
        ensure_selection_visible
      end
    end

    private def start_filtering
      @filtering = true
      @filter.focus
    end

    private def stop_filtering
      @filtering = false
      @filter.blur
    end

    private def submit_selection
      # For now, just update value (already done on selection move)
      # In a form, this would trigger next field
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
      # Ensure selected index stays within bounds
      @selected = @selected.clamp(0, Math.max(0, @filtered_options.size - 1))
    end

    private def ensure_selection_visible
      # TODO: adjust viewport y_offset to keep selected option visible
    end
  end
end
