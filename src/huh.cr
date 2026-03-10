require "bubbletea"
require "lipgloss"
require "./huh/layout"
require "./huh/keymap"

# Crystal port of charmbracelet/huh
#
# A simple, powerful library for building interactive forms and prompts in the terminal.
#
# ## Quick Start
#
# ```
# require "huh"
#
# # Create a simple form
# form = Huh.new_form(
#   Huh.new_group(
#     Huh.new_input
#       .title("What's your name?")
#       .value(pointerof(name)),
#     Huh.new_confirm
#       .title("Are you sure?")
#       .value(pointerof(confirmed))
#   )
# )
#
# form.run
# puts "Hello, #{name}!" if confirmed
# ```
#
# ## Features
#
# - **Easy form building** with groups and fields
# - **Multiple field types**: Input, Text, Select, MultiSelect, Confirm, Note
# - **Validation** with custom validation functions
# - **Theming support** with several built-in themes
# - **Bubble Tea integration** for embedding in TUI applications
#
# ## Field Types
#
# - `Huh.new_input` - Single line text input
# - `Huh.new_text` - Multi-line text input
# - `Huh.new_select` - Select an option from a list
# - `Huh.new_multiselect` - Select multiple options from a list
# - `Huh.new_confirm` - Confirm an action (yes or no)
# - `Huh.new_note` - Display informational text
#
# ## Examples
#
# See the examples directory for complete working examples.
#
module Huh
  VERSION = "0.1.0"

  # Error raised when a form run is interrupted by the user.
  class UserAbortedError < Exception
  end

  # Error raised when a form run exceeds configured timeout.
  class TimeoutError < Exception
  end

  # Error raised when timeout is used in accessible mode.
  class TimeoutUnsupportedError < Exception
  end

  # Use bubbletea v2.0.0 for terminal UI
  alias Tea = Bubbletea
  alias Cmd = Tea::Cmd?
  alias Model = Tea::Model
  # Msg is a module that all message types include
  # KeyPressMsg and WindowSizeMsg are specific message types

  # Re-export lipgloss for styling
  alias Style = Lipgloss::Style
  alias Color = Lipgloss::Color
end

# Load core components
require "./huh/theme"
require "./huh/field"
require "./huh/accessor"
require "./huh/selector"
require "./huh/eval"
require "./huh/runtime_model"
require "./huh/form"
require "./huh/fields/input"
require "./huh/fields/confirm"
require "./huh/fields/select"
require "./huh/fields/multiselect"
require "./huh/fields/note"
require "./huh/fields/text"
require "./huh/fields/filepicker"
require "./huh/spinner/spinner"

# Extend module with factory functions
module Huh
  # Factory functions
  def self.new_form(*groups : Group) : Form
    Form.new(*groups)
  end

  def self.new_group(*fields : FieldBase) : Group
    Group.new(*fields)
  end

  def self.new_input : Input
    Input.new
  end

  def self.new_confirm : Confirm
    Confirm.new
  end

  def self.new_select(type : T.class) : Select(T) forall T
    Select(T).new
  end

  def self.new_multiselect(type : T.class) : MultiSelect(T) forall T
    MultiSelect(T).new
  end

  def self.new_note : Note
    Note.new
  end

  def self.new_text : Text
    Text.new
  end

  def self.new_filepicker : FilePicker
    FilePicker.new
  end

  # LayoutColumns creates a column layout with the given number of columns.
  def self.layout_columns(columns : Int32) : Layout::LayoutBase
    Layout.layout_columns(columns)
  end

  # LayoutGrid creates a grid layout with the given number of rows and columns.
  def self.layout_grid(rows : Int32, columns : Int32) : Layout::LayoutBase
    Layout.layout_grid(rows, columns)
  end

  # Cell creates a mutable reference to a value, used for field value binding.
  #
  # ```
  # name = Huh.cell("") # Creates Cell(String)
  # field.value(name)
  # form.run
  # puts name.value
  # ```
  def self.cell(value : T) : Cell(T) forall T
    Cell(T).new(value)
  end

  # Backward-compatible alias for previous API name.
  def self.ref(value : T) : Cell(T) forall T
    cell(value)
  end
end
