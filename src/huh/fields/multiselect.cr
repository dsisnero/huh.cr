require "../option"
require "../eval"
require "../utils"
require "bubbles"
require "lipgloss"

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
    @viewport : Bubbles::Viewport::Model

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
    @filter : Bubbles::TextInput::Model
    @spinner : Bubbles::Spinner::Model

    # Configuration
    property? filterable : Bool = true
    property limit : Int32 = 0
    property width : Int32 = 0
    property height : Int32 = 0
    property? accessible : Bool = false
    property theme : Theme? = nil
    property keymap : MultiSelectKeyMap? = nil

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
      @validate = Proc(Array(T), Exception | Nil).new { nil }

      # Call parent initializer with initial value
      super(@accessor.get)
    end

    # Value sets the value of the multi-select field using a ref
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
      @title_eval.function(fn)
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
      @description_eval.function(fn)
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
      @options_eval.function(fn)
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
      set_filtering(filtering)
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
      @keymap = keymap.multiselect
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
          select_options(@accessor.get)
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

        # Check for filtering control keys.
        case msg
        when Tea::KeyPressMsg
          case msg.string
          when "enter"
            if @filtered_options.empty?
              clear_filter
            end
            stop_filtering
          when "esc"
            if @filtered_options.empty?
              clear_filter
            end
            stop_filtering
          when "tab"
            stop_filtering
            return {self, submit}
          end
        end
        return {self, cmd}
      end

      case msg
      when Tea::KeyPressMsg
        if key_in?(msg, "up", "k", "ctrl+k", "ctrl+p")
          move_cursor(-1)
        elsif key_in?(msg, "down", "j", "ctrl+j", "ctrl+n")
          move_cursor(1)
        elsif key_in?(msg, "home", "g")
          goto_top
        elsif key_in?(msg, "end", "G")
          goto_bottom
        elsif key_in?(msg, "ctrl+u")
          half_page_up
        elsif key_in?(msg, "ctrl+d")
          half_page_down
        elsif key_in?(msg, "x", "space", " ")
          toggle_selection
        elsif key_in?(msg, "shift+tab")
          cmd = prev
        elsif key_in?(msg, "enter", "tab")
          cmd = submit
        elsif key_in?(msg, "/")
          start_filtering if @filterable
        elsif key_in?(msg, "esc")
          clear_filter
        elsif key_in?(msg, "ctrl+a")
          toggle_select_all if @limit <= 0
        end
      end

      {self, cmd}
    end

    def view : String
      styles = active_styles
      update_viewport_height
      options = options_view
      @viewport.content = options

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
      clear_filter
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
      binds = [
        KeyBinding.new(:toggle, ["x", "space"], "toggle"),
        KeyBinding.new(:up, ["up", "k", "ctrl+k", "ctrl+p"], "up"),
        KeyBinding.new(:down, ["down", "j", "ctrl+j", "ctrl+n"], "down"),
        KeyBinding.new(:goto_top, ["g", "home"], "first"),
        KeyBinding.new(:goto_bottom, ["G", "end"], "last"),
        KeyBinding.new(:half_page_up, ["ctrl+u"], "half page up"),
        KeyBinding.new(:half_page_down, ["ctrl+d"], "half page down"),
        KeyBinding.new(:submit, ["enter"], "submit"),
      ]
      binds << KeyBinding.new(:filter, ["/"], "filter") if @filterable
      binds
    end

    def run_accessible(writer : IO, reader : IO) : Nil
      styles = active_styles
      writer << styles.title.render(@title_eval.value) << "\n"

      # List options
      @options_eval.value.each_with_index do |option, i|
        writer << "#{i + 1}. #{option.key}\n"
      end

      writer << "\n"
      writer << "Choose multiple options separated by commas (e.g., 1,3,5):\n"

      # Prompt for choices
      loop do
        input = Accessibility.prompt_string(writer, reader, "Choices: ")
        choices = input.split(',').map(&.strip)

        selected_indices = [] of Int32
        valid = true

        choices.each do |choice_str|
          begin
            choice = choice_str.to_i32
            if choice < 1 || choice > @options_eval.value.size
              writer << "Invalid choice: #{choice}. Please choose between 1 and #{@options_eval.value.size}\n"
              valid = false
              break
            end
            selected_indices << choice - 1
          rescue
            writer << "Invalid input: #{choice_str}. Please enter numbers separated by commas.\n"
            valid = false
            break
          end
        end

        next unless valid

        # Get selected values
        selected_values = selected_indices.map { |i| @options_eval.value[i].value }

        # Validate the choices
        err = @validate.call(selected_values)
        if err
          writer << err.message << "\n"
          next
        end

        # Update selection
        @options_eval.value.each_with_index do |option, i|
          option.selected = selected_indices.includes?(i)
        end

        selected_keys = selected_indices.map { |i| @options_eval.value[i].key }
        writer << styles.selected_option.render("Chose: " + selected_keys.join(", ") + "\n")
        @accessor.set(selected_values)
        @value = @accessor.get
        break
      end
    end

    # Private methods

    private def select_options(values : Array(T))
      # Mark options as selected based on current values
      @options_eval.value.each do |option|
        option.selected = values.includes?(option.value)
      end
      # Set cursor to first selected option or 0
      @options_eval.value.each_with_index do |option, i|
        if option.selected?
          @cursor = i
          break
        end
      end
      @viewport.y_offset = @cursor
    end

    private def update_value
      selected_values = [] of T
      @options_eval.value.each do |option|
        if option.selected?
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

      offset = 0
      title = title_view
      offset += Lipgloss.height(title) unless title.empty?
      description = description_view
      offset += Lipgloss.height(description) unless description.empty?

      @viewport.height = Math.max(MIN_HEIGHT, @height - offset)
      @viewport.y_offset = @viewport.y_offset.clamp(0, Math.max(0, @filtered_options.size - 1))
    end

    private def clear_filter
      @filter.value = ""
      @filtered_options = @options_eval.value
      set_filtering(false)
    end

    private def set_filtering(filtering : Bool)
      @filtering = filtering
      keymap = @keymap || Huh::DEFAULT_KEYMAP.multiselect
      keymap.set_filter.set_enabled(filtering)
      keymap.filter.set_enabled(!filtering)
      keymap.clear_filter.set_enabled(!filtering && !@filter.value.empty?)
      keymap.next.set_enabled(!filtering)
      keymap.submit.set_enabled(!filtering)
      keymap.prev.set_enabled(!filtering)
    end

    private def title_view : String
      styles = active_styles
      max_width = @width - styles.base.horizontal_frame_size
      sb = String::Builder.new

      if @filtering
        # Apply styles to filter text input
        apply_filter_styles
        sb << @filter.view
      elsif !@filter.value.empty?
        sb << styles.description.render("/" + @filter.value)
      else
        sb << styles.title.render(Huh.wrap(@title_eval.value, max_width))
      end

      if @error
        sb << styles.error_indicator.render("")
      end

      sb.to_s
    end

    private def description_view : String
      return "" if @description_eval.value.empty?
      styles = active_styles
      max_width = @width - styles.base.horizontal_frame_size
      styles.description.render(Huh.wrap(@description_eval.value, max_width))
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

    private def options_view : String
      sb = String::Builder.new
      @filtered_options.each_with_index do |option, i|
        cursor = @cursor == i
        selected = option.selected?
        sb << render_option(option, cursor, selected)
        sb << "\n" if i < @filtered_options.size - 1
      end
      sb.to_s
    end

    private def render_option(option : Option(T), cursor : Bool, selected : Bool) : String
      styles = active_styles

      # Get styled cursor ("> " or "  ")
      cursor_style = styles.multiselect_selector
      cursor_text = cursor_style.render("")
      cursor_width = Lipgloss::Text.width(cursor_text)

      # Get prefix style (selected/unselected)
      prefix_style = selected ? styles.selected_prefix : styles.unselected_prefix
      prefix_text = prefix_style.render("")
      prefix_width = Lipgloss::Text.width(prefix_text)

      # Calculate available width for option key
      max_width = @width - styles.base.horizontal_frame_size - cursor_width - prefix_width
      key = Huh.wrap(option.key, max_width)

      # Build the line
      if cursor
        Lipgloss.join_horizontal(Lipgloss::Position::Left,
          cursor_text,
          prefix_text,
          (selected ? styles.selected_option : styles.unselected_option).render(key)
        )
      else
        Lipgloss.join_horizontal(Lipgloss::Position::Left,
          " " * cursor_width,
          prefix_text,
          (selected ? styles.selected_option : styles.unselected_option).render(key)
        )
      end
    end

    private def move_cursor(delta : Int32)
      return if @filtered_options.empty?

      new_index = @cursor + delta
      if new_index >= 0 && new_index < @filtered_options.size
        @cursor = new_index
        # Adjust viewport to keep cursor visible
        ensure_cursor_visible
      end
    end

    private def goto_top
      return if @filtered_options.empty?
      @cursor = 0
      ensure_cursor_visible
    end

    private def goto_bottom
      return if @filtered_options.empty?
      @cursor = @filtered_options.size - 1
      ensure_cursor_visible
    end

    private def half_page_up
      return if @filtered_options.empty?
      step = Math.max(1, @viewport.height // 2)
      @cursor = Math.max(0, @cursor - step)
      ensure_cursor_visible
    end

    private def half_page_down
      return if @filtered_options.empty?
      step = Math.max(1, @viewport.height // 2)
      @cursor = Math.min(@filtered_options.size - 1, @cursor + step)
      ensure_cursor_visible
    end

    private def toggle_selection
      return if @filtered_options.empty?

      option = @filtered_options[@cursor]
      # Check limit constraint
      if !option.selected? && @limit > 0 && num_selected >= @limit
        return
      end

      # Toggle selection in both filtered and original options
      option.selected = !option.selected?
      # Also update the original option
      @options_eval.value.each_with_index do |orig_option, i|
        if orig_option.key == option.key
          @options_eval.value[i].selected = option.selected?
          break
        end
      end

      update_value
    end

    private def start_filtering
      set_filtering(true)
      @filter.focus
    end

    private def stop_filtering
      set_filtering(false)
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
      ensure_cursor_visible
    end

    private def ensure_cursor_visible
      return if @filtered_options.empty?

      if @cursor < @viewport.y_offset
        @viewport.y_offset = @cursor
      elsif @cursor >= @viewport.y_offset + @viewport.height
        @viewport.y_offset = @cursor - @viewport.height + 1
      end
    end

    private def submit : Tea::Cmd?
      update_value
      @error = @validate.call(@accessor.get)
      return nil if @error
      Tea.batch([-> : ::Tea::Msg? { Huh.next_field }])
    end

    private def prev : Tea::Cmd?
      update_value
      @error = @validate.call(@accessor.get)
      return nil if @error
      Tea.batch([-> : ::Tea::Msg? { Huh.prev_field }])
    end

    private def key_in?(msg : Tea::KeyPressMsg, *keys : String) : Bool
      key = msg.string
      stroke = msg.keystroke
      keys.any? { |k| k == key || k == stroke }
    end

    private def num_filtered_selected : Int32
      count = 0
      @filtered_options.each do |option|
        count += 1 if option.selected?
      end
      count
    end

    private def toggle_select_all
      # Only allowed when limit <= 0 (no limit)
      return if @limit > 0

      any_unselected = false
      @filtered_options.each do |option|
        if !option.selected?
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
        count += 1 if option.selected?
      end
      count
    end
  end
end
