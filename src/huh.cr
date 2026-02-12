require "term2"
require "lipgloss"

# Crystal port of charmbracelet/huh
# A simple, powerful library for building interactive forms and prompts in the terminal.
module Huh
  VERSION = "0.1.0"

  # Include term2 and lipgloss for terminal UI
  include Term2::Prelude
  alias Cmd = Term2::Cmd
  alias Cmds = Term2::Cmds
  alias Model = Term2::Model
  alias Msg = Term2::Msg
  alias KeyMsg = Term2::KeyMsg
  alias WindowSizeMsg = Term2::WindowSizeMsg

  # Re-export lipgloss for styling
  alias Style = Lipgloss::Style
  alias Color = Lipgloss::Color
end

# Load core components
require "./huh/field"
require "./huh/accessor"
require "./huh/selector"
require "./huh/eval"
require "./huh/form"
require "./huh/fields/input"
require "./huh/fields/confirm"
require "./huh/fields/select"
require "./huh/fields/multiselect"

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
end
