require "../option"
require "../eval"
require "../utils"
require "bubbles"
require "lipgloss"

module Huh
  # Select field for choosing a single option from a list.
  #
  # Allows users to select one option from a list of choices. Supports filtering,
  # keyboard navigation, and dynamic option loading.
  #
  # ## Example
  #
  # ```
  # country = ""
  #
  # Huh.new_select(String)
  #   .title("Choose a country")
  #   .options([
  #     Huh::Option.new("United States", "US"),
  #     Huh::Option.new("Canada", "CA"),
  #     Huh::Option.new("Mexico", "MX"),
  #   ])
  #   .value(pointerof(country))
  #   .run
  #
  # puts "Selected: #{country}"
  # ```
  #
  # ## Features
  #
  # - **Filtering**: Type "/" to filter options
  # - **Keyboard navigation**: Up/Down, j/k, Ctrl+N/Ctrl+P
  # - **Dynamic options**: Load options dynamically with `options_func`
  # - **Custom heights**: Control visible option count
  # - **Validation**: Validate selected option
  #
  class Select(T) < Field(T)
    # Internal accessor
    @accessor : Accessor(T)

    # Viewport for scrolling options
    @viewport : Bubbles::Viewport::Model

    # Filter input component
    @filter : Bubbles::TextInput::Model
    @spinner : Bubbles::Spinner::Model

    # Evaluatable fields
    @title_eval : Eval(String)
    @description_eval : Eval(String)
    @options_eval : Eval(Array(Option(T)))

    # Filtered options based on filter input
    @filtered_options : Array(Option(T))

    # Validation
    @validate : Proc(T, Exception | Nil)
    @error : Exception?

    # Selection state
    @selected : Int32
    @focused : Bool
    @filtering : Bool

    # Configuration
    property? inline : Bool = false
    property width : Int32 = 0
    property height : Int32 = 0
    property? accessible : Bool = false
    property theme : Theme? = nil
    property keymap : SelectKeyMap? = nil

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
      @viewport = Bubbles::Viewport::Model.new

      # Initialize eval objects
      @title_eval = Eval(String).new("")
      @description_eval = Eval(String).new("")
      @options_eval = Eval(Array(Option(T))).new([] of Option(T))
      @filtered_options = [] of Option(T)

      # Initialize filter input
      @filter = Bubbles::TextInput::Model.new
      @filter.prompt = "/"

      # Initialize spinner
      @spinner = Bubbles::Spinner::Model.new

      # Default validation (always passes)
      @validate = Proc(T, Exception | Nil).new { nil }

      # Initialize state
      @selected = 0
      @focused = false
      @filtering = false
      @error = nil

      # Call parent initializer with initial value
      super(@accessor.get)
    end

    # Value sets the value of the select field using a ref
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
      @title_eval.function(fn)
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
      @description_eval.function(fn)
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
      @options_eval.function(fn)
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
      self
    end

    # Width setter (property)
    def width=(width : Int32)
      @width = width
      @viewport.width = width
    end

    # Override with_width to also set viewport width
    def with_width(width : Int32) : self
      super
      @viewport.width = width
      self
    end

    # Theme configuration
    def theme(theme : Theme) : self
      @theme = theme
      self
    end

    # Keymap configuration
    def keymap(keymap : KeyMap) : self
      @keymap = keymap.select
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
      @filter.init
    end

    def focused? : Bool
      @focused
    end

    def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
      cmd = nil

      if msg.is_a?(Huh::UpdateFieldMsg)
        @title_eval.update
        @description_eval.update
        if @options_eval.update
          @filtered_options = @options_eval.value
          select_value(@accessor.get)
          update_viewport_height
          update_value
          update_filtered_options if @filtering
        end
        return {self, nil}
      end

      if @filtering
        # Delegate to filter input
        @filter, cmd = @filter.update(msg)
        # Update filtered options based on filter value
        update_filtered_options

        # Check for filtering control keys
        case msg
        when Tea::KeyPressMsg
          case msg.string
          when "esc"
            stop_filtering
            return {self, cmd}
          when "enter", "tab"
            stop_filtering
            return {self, submit_selection}
          end
        end
        return {self, cmd}
      end

      case msg
      when Tea::KeyPressMsg
        key = msg.string
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
          cmd = submit_selection
        when "esc"
          clear_filter
        end
      end

      {self, cmd}
    end

    def view : String
      styles = active_styles
      update_viewport_height
      @viewport.content = options_view

      parts = [] of String
      title = title_view
      parts << title unless title.empty?
      description = description_view
      parts << description unless description.empty?
      parts << @viewport.view

      styles.base
        .width(@width)
        .height(@height)
        .render(parts.join("\n"))
    end

    def blur : Tea::Cmd?
      value = @accessor.get
      if @inline
        clear_filter
        select_value(value)
      end
      @focused = false
      @error = @validate.call(value)
      nil
    end

    def focus : Tea::Cmd?
      @focused = true
      nil
    end

    def skip : Bool
      false
    end

    def zoom : Bool
      false
    end

    def key_binds : Array(KeyBinding)
      [
        KeyBinding.new(:up, ["up", "k", "ctrl+k", "ctrl+p"], "up"),
        KeyBinding.new(:down, ["down", "j", "ctrl+j", "ctrl+n"], "down"),
        KeyBinding.new(:filter, ["/"], "filter"),
        KeyBinding.new(:submit, ["enter"], "submit"),
      ]
    end

    def run_accessible(writer : IO, reader : IO) : Nil
      styles = active_styles
      writer << styles.title.render(@title_eval.value) << "\n"

      # List options
      @options_eval.value.each_with_index do |option, i|
        writer << "#{i + 1}. #{option.key}\n"
      end

      writer << "\n"

      # Prompt for choice
      loop do
        choice = Accessibility.prompt_int(writer, reader, "Choose: ", 1, @options_eval.value.size)
        option = @options_eval.value[choice - 1]

        # Validate the choice
        err = @validate.call(option.value)
        if err
          writer << err.message << "\n"
          next
        end

        writer << styles.selected_option.render("Chose: " + option.key + "\n")
        @accessor.set(option.value)
        @value = @accessor.get
        break
      end
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
        if option.selected?
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
        # Calculate height from number of options
        height = @filtered_options.size
        # Ensure at least MIN_HEIGHT
        @viewport.height = Math.max(MIN_HEIGHT, height)
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
        sb << @filter.view
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
      input_styles = Bubbles::TextInput::Styles.new

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
      cursor_color = cursor_style.foreground_color
      input_styles.cursor.color = cursor_color || Lipgloss.color("7")
      input_styles.cursor.shape = Tea::CursorStyle::Block

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
        sb << "\n" if i < @options_eval.value.size - 1
      end

      # Keep viewport row count stable against full option list, matching Go behavior.
      @filtered_options.size.upto(@options_eval.value.size - 2) do
        sb << "\n"
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

      prev_indicator = styles.prev_indicator.faint(@selected <= 0).render("")
      next_indicator = styles.next_indicator.faint(@selected == @filtered_options.size - 1).render("")

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

      # Get cursor string from style, or use default "> " if empty
      cursor = styles.select_selector.string
      if cursor.empty?
        cursor = "> "
      end
      # Strip ANSI codes to get visual width
      cursor_visual = Ansi.strip(cursor)
      cursor_width = Lipgloss::Text.width(cursor_visual)
      max_width = @width - styles.base.horizontal_frame_size - cursor_width

      key = Huh.wrap(option.key, max_width)

      if selected
        Lipgloss.join_horizontal(Lipgloss::Position::Left,
          cursor,
          styles.selected_option.render(key)
        )
      else
        spaces = " " * cursor_width
        Lipgloss.join_horizontal(Lipgloss::Position::Left,
          spaces,
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

    private def submit_selection : Tea::Cmd?
      return nil if @filtered_options.empty? || @selected >= @filtered_options.size

      update_value
      @error = @validate.call(@accessor.get)
      return nil if @error

      # Enter accepts current selection and advances field navigation.
      Tea.batch([-> : ::Tea::Msg? { Huh.next_field }])
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
