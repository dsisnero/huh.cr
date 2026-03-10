require "bubbles"
require "../utils"
require "../accessibility"

module Huh
  # FilePicker field for selecting files or directories.
  #
  # Allows users to navigate the filesystem and select files or directories.
  # Supports filtering by file type, showing/hiding hidden files, and custom
  # validation of selected paths.
  #
  # ## Example
  #
  # ```
  # file_path = ""
  #
  # Huh.new_filepicker
  #   .title("Select a configuration file")
  #   .current_directory(".")
  #   .allowed_types([".yaml", ".yml", ".json"])
  #   .file_allowed(true)
  #   .dir_allowed(false)
  #   .value(pointerof(file_path))
  #   .validate do |path|
  #     unless File.exists?(path)
  #       Exception.new("File does not exist")
  #     end
  #   end
  #   .run
  #
  # puts "Selected: #{file_path}"
  # ```
  #
  # ## Features
  #
  # - **Filesystem navigation**: Browse directories and select files
  # - **File type filtering**: Restrict to specific file extensions
  # - **Hidden files**: Show or hide hidden files/directories
  # - **File info**: Show file sizes and permissions
  # - **Validation**: Validate selected paths
  #
  class FilePicker < Field(String)
    # Internal accessor
    @accessor : Accessor(String)

    # Internal filepicker component from Bubbles v2.0.0
    @filepicker : Bubbles::Filepicker::Model

    # Field configuration with eval
    @title_eval : Eval(String)
    @description_eval : Eval(String)

    # Field state
    property? inline : Bool = false
    property validate : Proc(String, Exception | Nil)
    property error : Exception? = nil
    property? accessible : Bool = false
    property width : Int32 = 0
    property height : Int32 = 0
    property theme : Theme? = nil
    property keymap : FilePickerKeyMap? = nil
    property? focused : Bool = false
    property? picking : Bool = false

    # FilePicker-specific configuration
    property? show_hidden : Bool = false
    property? show_size : Bool = false
    property? show_permissions : Bool = false
    property? file_allowed : Bool = true
    property? dir_allowed : Bool = true
    property allowed_types : Array(String) = [] of String

    # Create a new FilePicker field
    def initialize
      # Initialize with empty string embedded accessor
      @accessor = EmbeddedAccessor(String).new("")

      # Initialize Bubbles Filepicker component v2.0.0
      @filepicker = Bubbles::Filepicker::Model.new
      @filepicker.current_directory = Dir.current

      # Initialize eval objects
      @title_eval = Eval(String).new("")
      @description_eval = Eval(String).new("")

      # Default validation (always passes)
      @validate = Proc(String, Exception | Nil).new { nil }

      # Call parent initializer with initial value
      super(@accessor.get)
    end

    # Value sets the value of the filepicker field using a ref
    def value(cell : Cell(String)) : self
      @accessor = PointerAccessor(String).new(cell)
      @value = @accessor.get
      self
    end

    # Accessor sets the accessor of the filepicker field
    def accessor(accessor : Accessor(String)) : self
      @accessor = accessor
      @value = @accessor.get
      self
    end

    # Key sets the key of the filepicker field which can be used to retrieve the value
    # after submission.
    def key(key : String) : self
      @key = key
      self
    end

    # Title sets the title of the filepicker field.
    def title(title : String) : self
      @title_eval.value = title
      @title = title
      self
    end

    # TitleFunc sets the title func of the filepicker field.
    def title_func(fn : Proc(String)) : self
      @title_eval.function(fn)
      self
    end

    # Description sets the description of the filepicker field.
    def description(description : String) : self
      @description_eval.value = description
      @description = description
      self
    end

    # DescriptionFunc sets the description func of the filepicker field.
    def description_func(fn : Proc(String)) : self
      @description_eval.function(fn)
      self
    end

    # CurrentDirectory sets the starting directory for the filepicker.
    def current_directory(directory : String) : self
      @filepicker.current_directory = directory
      self
    end

    # Picking sets whether the filepicker is in picking mode.
    def picking(picking : Bool) : self
      @picking = picking
      self
    end

    # ShowHidden sets whether to show hidden files.
    def show_hidden(show : Bool) : self
      @show_hidden = show
      @filepicker.show_hidden = show
      self
    end

    # ShowSize sets whether to show file sizes.
    def show_size(show : Bool) : self
      @show_size = show
      @filepicker.show_size = show
      self
    end

    # ShowPermissions sets whether to show file permissions.
    def show_permissions(show : Bool) : self
      @show_permissions = show
      @filepicker.show_permissions = show
      self
    end

    # FileAllowed sets whether files can be selected.
    def file_allowed(allowed : Bool) : self
      @file_allowed = allowed
      @filepicker.file_allowed = allowed
      self
    end

    # DirAllowed sets whether directories can be selected.
    def dir_allowed(allowed : Bool) : self
      @dir_allowed = allowed
      @filepicker.dir_allowed = allowed
      self
    end

    # AllowedTypes sets the allowed file types (extensions).
    def allowed_types(types : Array(String)) : self
      @allowed_types = types
      @filepicker.allowed_types = types
      self
    end

    # Height sets the height of the filepicker field.
    def height(height : Int32) : self
      @height = height
      adjust = 0
      if @title && !@title.empty?
        adjust += 1
      end
      if @description && !@description.empty?
        adjust += 1
      end
      @filepicker.height = height - adjust
      self
    end

    # Width sets the width of the filepicker field.
    def width(width : Int32) : self
      @width = width
      self
    end

    # Validate sets the validation function.
    def validate(&block : String -> Exception | Nil) : self
      @validate = block
      self
    end

    # Validate sets the validation function with a proc.
    def validate(validate : Proc(String, Exception | Nil)) : self
      @validate = validate
      self
    end

    # WithAccessible sets the accessible mode.
    def with_accessible(accessible : Bool) : self
      @accessible = accessible
      self
    end

    # Accessible sets the accessible mode (alias for with_accessible).
    def accessible(accessible : Bool) : self
      @accessible = accessible
      self
    end

    # WithTheme sets the theme.
    def with_theme(theme : Theme) : self
      @theme = theme
      self
    end

    # Theme sets the theme (alias for with_theme).
    def theme(theme : Theme) : self
      @theme = theme
      self
    end

    # WithKeyMap sets the keymap.
    def with_key_map(keymap : KeyMap) : self
      @keymap = keymap.filepicker
      self
    end

    # KeyMap sets the keymap (alias for with_key_map).
    def key_map(keymap : KeyMap) : self
      @keymap = keymap.filepicker
      self
    end

    # Implement field_keymap abstract method
    def field_keymap : Object?
      @keymap
    end

    # Inline sets whether the field should be rendered inline.
    def inline(inline : Bool) : self
      @inline = inline
      self
    end

    # Error returns the current validation error.
    def error : Exception?
      @error
    end

    # Skip returns whether the field should be skipped.
    def skip : Bool
      false
    end

    # Zoom returns whether the field is in zoom/picking mode.
    def zoom : Bool
      @picking
    end

    # Focused? returns whether the field is focused.
    def focused? : Bool
      @focused
    end

    # Focus focuses the field.
    def focus : Tea::Cmd?
      @focused = true
      @filepicker.init
    end

    # Blur blurs the field.
    def blur : Tea::Cmd?
      @focused = false
      @picking = false
      @error = @validate.call(@accessor.get)
      nil
    end

    # KeyBinds returns the key bindings for help text.
    def key_binds : Array(KeyBinding)
      [
        KeyBinding.new(:up, ["up", "k"], "up"),
        KeyBinding.new(:down, ["down", "j"], "down"),
        KeyBinding.new(:select, ["enter"], "select"),
        KeyBinding.new(:back, ["esc"], "back"),
      ]
    end

    # Init initializes the field.
    def init : Tea::Cmd?
      @filepicker.init
    end

    # Update handles messages.
    def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
      if msg.is_a?(Huh::UpdateFieldMsg)
        @title_eval.update
        @description_eval.update
        return {self, nil}
      end

      case msg
      when Tea::KeyPressMsg
        key = msg.string
        if @focused
          # Handle filepicker-specific keys
          case key
          when "enter"
            # TODO: Get selected file from filepicker
            # For now, just move to next field
            return {self, Tea.batch([-> : ::Tea::Msg? { NextFieldMsg.new }])}
          when "esc"
            @picking = false
            return {self, nil}
          when "/"
            @picking = !@picking
            return {self, nil}
          end
        end
      end

      # Delegate to filepicker component
      filepicker, cmd = @filepicker.update(msg)
      @filepicker = filepicker.as(Bubbles::Filepicker::Model)

      # TODO: Update value when filepicker has selection
      # Currently Bubbles filepicker doesn't expose selected file directly

      {self, cmd}
    end

    # View renders the field.
    def view : String
      # Get current title and description
      title = @title_eval.value
      description = @description_eval.value

      # Get active styles based on focus state
      styles = active_styles

      # Build the view
      io = IO::Memory.new

      # Title
      if !title.empty?
        io << styles.title.render(title)
        io << "\n"
      end

      # Description
      if !description.empty?
        io << styles.description.render(description)
        io << "\n"
      end

      # Filepicker view
      filepicker_view = @filepicker.view
      io << styles.base.render(filepicker_view)

      # Error message
      if error = @error
        io << "\n"
        io << styles.error_message.render("✗ " + (error.message || "Error"))
      end

      io.to_s
    end

    # Run runs the field in standalone mode.
    def run : Nil
      program = Tea::Program.new(Huh::RuntimeModel(FilePicker).new(self))
      program.run
    end

    # RunAccessible runs the field in accessible mode.
    def run_accessible(writer : IO, reader : IO) : Nil
      styles = active_styles
      writer << styles.title.render(@title_eval.value) << "\n\n"

      # Use accessibility module for prompting
      path = Accessibility.prompt_string(writer, reader, "Select file (enter path): ", ->(s : String) do
        err = @validate.call(s)
        err ? err.message : nil
      end)

      @value = path
      @accessor.set(@value)
      writer << styles.selected_option.render("Selected: " + @value + "\n")
    end

    # Get returns the current value.
    def get : String
      @accessor.get
    end

    # Set sets the current value.
    def set(value : String) : Nil
      @accessor.set(value)
      @value = value
      validate_field
    end

    private def validate_field
      @error = @validate.call(@accessor.get)
    rescue e : Exception
      @error = e
    end
  end
end
