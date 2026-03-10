require "bubbles"

module Huh
  # KeyMap is the keybindings to navigate the form.
  class KeyMap
    property quit : Bubbles::Key::Binding

    # Field-specific keymaps
    property confirm : ConfirmKeyMap
    property filepicker : FilePickerKeyMap
    property input : InputKeyMap
    property multiselect : MultiSelectKeyMap
    property note : NoteKeyMap
    property select : SelectKeyMap
    property text : TextKeyMap

    def initialize
      @quit = Bubbles::Key::Binding.new(keys: ["ctrl+c", "esc"])

      # Initialize with default keymaps
      @confirm = ConfirmKeyMap.new
      @filepicker = FilePickerKeyMap.new
      @input = InputKeyMap.new
      @multiselect = MultiSelectKeyMap.new
      @note = NoteKeyMap.new
      @select = SelectKeyMap.new
      @text = TextKeyMap.new
    end
  end

  # InputKeyMap is the keybindings for input fields.
  class InputKeyMap
    property accept_suggestion : Bubbles::Key::Binding
    property next : Bubbles::Key::Binding
    property prev : Bubbles::Key::Binding
    property submit : Bubbles::Key::Binding

    def initialize
      @accept_suggestion = Bubbles::Key::Binding.new(
        keys: ["ctrl+e"],
        help: Bubbles::Key::Help.new(key: "ctrl+e", desc: "complete")
      )
      @prev = Bubbles::Key::Binding.new(
        keys: ["shift+tab"],
        help: Bubbles::Key::Help.new(key: "shift+tab", desc: "back")
      )
      @next = Bubbles::Key::Binding.new(
        keys: ["enter", "tab"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "next")
      )
      @submit = Bubbles::Key::Binding.new(
        keys: ["enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "submit")
      )
    end
  end

  # TextKeyMap is the keybindings for text fields.
  class TextKeyMap
    property next : Bubbles::Key::Binding
    property prev : Bubbles::Key::Binding
    property new_line : Bubbles::Key::Binding
    property editor : Bubbles::Key::Binding
    property submit : Bubbles::Key::Binding

    def initialize
      @prev = Bubbles::Key::Binding.new(
        keys: ["shift+tab"],
        help: Bubbles::Key::Help.new(key: "shift+tab", desc: "back")
      )
      @next = Bubbles::Key::Binding.new(
        keys: ["tab", "enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "next")
      )
      @submit = Bubbles::Key::Binding.new(
        keys: ["enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "submit")
      )
      @new_line = Bubbles::Key::Binding.new(
        keys: ["alt+enter", "ctrl+j"],
        help: Bubbles::Key::Help.new(key: "alt+enter / ctrl+j", desc: "new line")
      )
      @editor = Bubbles::Key::Binding.new(
        keys: ["ctrl+e"],
        help: Bubbles::Key::Help.new(key: "ctrl+e", desc: "open editor")
      )
    end
  end

  # SelectKeyMap is the keybindings for select fields.
  class SelectKeyMap
    property next : Bubbles::Key::Binding
    property prev : Bubbles::Key::Binding
    property up : Bubbles::Key::Binding
    property down : Bubbles::Key::Binding
    property half_page_up : Bubbles::Key::Binding
    property half_page_down : Bubbles::Key::Binding
    property goto_top : Bubbles::Key::Binding
    property goto_bottom : Bubbles::Key::Binding
    property left : Bubbles::Key::Binding
    property right : Bubbles::Key::Binding
    property filter : Bubbles::Key::Binding
    property set_filter : Bubbles::Key::Binding
    property clear_filter : Bubbles::Key::Binding
    property submit : Bubbles::Key::Binding

    def initialize
      @prev = Bubbles::Key::Binding.new(
        keys: ["shift+tab"],
        help: Bubbles::Key::Help.new(key: "shift+tab", desc: "back")
      )
      @next = Bubbles::Key::Binding.new(
        keys: ["enter", "tab"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "select")
      )
      @submit = Bubbles::Key::Binding.new(
        keys: ["enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "submit")
      )
      @up = Bubbles::Key::Binding.new(
        keys: ["up", "k", "ctrl+k", "ctrl+p"],
        help: Bubbles::Key::Help.new(key: "↑", desc: "up")
      )
      @down = Bubbles::Key::Binding.new(
        keys: ["down", "j", "ctrl+j", "ctrl+n"],
        help: Bubbles::Key::Help.new(key: "↓", desc: "down")
      )
      @half_page_up = Bubbles::Key::Binding.new(
        keys: ["ctrl+u"],
        help: Bubbles::Key::Help.new(key: "ctrl+u", desc: "half page up")
      )
      @half_page_down = Bubbles::Key::Binding.new(
        keys: ["ctrl+d"],
        help: Bubbles::Key::Help.new(key: "ctrl+d", desc: "half page down")
      )
      @goto_top = Bubbles::Key::Binding.new(
        keys: ["home", "g"],
        help: Bubbles::Key::Help.new(key: "g", desc: "first")
      )
      @goto_bottom = Bubbles::Key::Binding.new(
        keys: ["end", "G"],
        help: Bubbles::Key::Help.new(key: "G", desc: "last")
      )
      @left = Bubbles::Key::Binding.new(
        keys: ["h", "left"],
        help: Bubbles::Key::Help.new(key: "←", desc: "left"),
        disabled: true
      )
      @right = Bubbles::Key::Binding.new(
        keys: ["l", "right"],
        help: Bubbles::Key::Help.new(key: "→", desc: "right"),
        disabled: true
      )
      @filter = Bubbles::Key::Binding.new(
        keys: ["/"],
        help: Bubbles::Key::Help.new(key: "/", desc: "filter")
      )
      @set_filter = Bubbles::Key::Binding.new(
        keys: ["esc"],
        help: Bubbles::Key::Help.new(key: "esc", desc: "set filter"),
        disabled: true
      )
      @clear_filter = Bubbles::Key::Binding.new(
        keys: ["esc"],
        help: Bubbles::Key::Help.new(key: "esc", desc: "clear filter"),
        disabled: true
      )
    end
  end

  # MultiSelectKeyMap is the keybindings for multi-select fields.
  class MultiSelectKeyMap
    property next : Bubbles::Key::Binding
    property prev : Bubbles::Key::Binding
    property up : Bubbles::Key::Binding
    property down : Bubbles::Key::Binding
    property half_page_up : Bubbles::Key::Binding
    property half_page_down : Bubbles::Key::Binding
    property goto_top : Bubbles::Key::Binding
    property goto_bottom : Bubbles::Key::Binding
    property toggle : Bubbles::Key::Binding
    property filter : Bubbles::Key::Binding
    property set_filter : Bubbles::Key::Binding
    property clear_filter : Bubbles::Key::Binding
    property submit : Bubbles::Key::Binding
    property select_all : Bubbles::Key::Binding
    property select_none : Bubbles::Key::Binding

    def initialize
      @prev = Bubbles::Key::Binding.new(
        keys: ["shift+tab"],
        help: Bubbles::Key::Help.new(key: "shift+tab", desc: "back")
      )
      @next = Bubbles::Key::Binding.new(
        keys: ["enter", "tab"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "select")
      )
      @submit = Bubbles::Key::Binding.new(
        keys: ["enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "submit")
      )
      @up = Bubbles::Key::Binding.new(
        keys: ["up", "k", "ctrl+k", "ctrl+p"],
        help: Bubbles::Key::Help.new(key: "↑", desc: "up")
      )
      @down = Bubbles::Key::Binding.new(
        keys: ["down", "j", "ctrl+j", "ctrl+n"],
        help: Bubbles::Key::Help.new(key: "↓", desc: "down")
      )
      @half_page_up = Bubbles::Key::Binding.new(
        keys: ["ctrl+u"],
        help: Bubbles::Key::Help.new(key: "ctrl+u", desc: "half page up")
      )
      @half_page_down = Bubbles::Key::Binding.new(
        keys: ["ctrl+d"],
        help: Bubbles::Key::Help.new(key: "ctrl+d", desc: "half page down")
      )
      @goto_top = Bubbles::Key::Binding.new(
        keys: ["home", "g"],
        help: Bubbles::Key::Help.new(key: "g", desc: "first")
      )
      @goto_bottom = Bubbles::Key::Binding.new(
        keys: ["end", "G"],
        help: Bubbles::Key::Help.new(key: "G", desc: "last")
      )
      @toggle = Bubbles::Key::Binding.new(
        keys: [" "],
        help: Bubbles::Key::Help.new(key: "space", desc: "toggle")
      )
      @filter = Bubbles::Key::Binding.new(
        keys: ["/"],
        help: Bubbles::Key::Help.new(key: "/", desc: "filter")
      )
      @set_filter = Bubbles::Key::Binding.new(
        keys: ["esc"],
        help: Bubbles::Key::Help.new(key: "esc", desc: "set filter"),
        disabled: true
      )
      @clear_filter = Bubbles::Key::Binding.new(
        keys: ["esc"],
        help: Bubbles::Key::Help.new(key: "esc", desc: "clear filter"),
        disabled: true
      )
      @select_all = Bubbles::Key::Binding.new(
        keys: ["ctrl+a"],
        help: Bubbles::Key::Help.new(key: "ctrl+a", desc: "select all")
      )
      @select_none = Bubbles::Key::Binding.new(
        keys: ["ctrl+a"],
        help: Bubbles::Key::Help.new(key: "ctrl+a", desc: "select none"),
        disabled: true
      )
    end
  end

  # ConfirmKeyMap is the keybindings for confirm fields.
  class ConfirmKeyMap
    property next : Bubbles::Key::Binding
    property prev : Bubbles::Key::Binding
    property toggle : Bubbles::Key::Binding
    property submit : Bubbles::Key::Binding
    property accept : Bubbles::Key::Binding
    property reject : Bubbles::Key::Binding

    def initialize
      @prev = Bubbles::Key::Binding.new(
        keys: ["shift+tab"],
        help: Bubbles::Key::Help.new(key: "shift+tab", desc: "back")
      )
      @next = Bubbles::Key::Binding.new(
        keys: ["enter", "tab"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "select")
      )
      @submit = Bubbles::Key::Binding.new(
        keys: ["enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "submit")
      )
      @toggle = Bubbles::Key::Binding.new(
        keys: ["left", "right", "h", "l"],
        help: Bubbles::Key::Help.new(key: "←/→", desc: "toggle")
      )
      @accept = Bubbles::Key::Binding.new(
        keys: ["y"],
        help: Bubbles::Key::Help.new(key: "y", desc: "accept")
      )
      @reject = Bubbles::Key::Binding.new(
        keys: ["n"],
        help: Bubbles::Key::Help.new(key: "n", desc: "reject")
      )
    end
  end

  # FilePickerKeyMap is the keybindings for filepicker fields.
  class FilePickerKeyMap
    property open : Bubbles::Key::Binding
    property close : Bubbles::Key::Binding
    property goto_top : Bubbles::Key::Binding
    property goto_last : Bubbles::Key::Binding
    property page_up : Bubbles::Key::Binding
    property page_down : Bubbles::Key::Binding
    property back : Bubbles::Key::Binding
    property select : Bubbles::Key::Binding
    property up : Bubbles::Key::Binding
    property down : Bubbles::Key::Binding
    property prev : Bubbles::Key::Binding
    property next : Bubbles::Key::Binding
    property submit : Bubbles::Key::Binding

    def initialize
      @goto_top = Bubbles::Key::Binding.new(
        keys: ["g"],
        help: Bubbles::Key::Help.new(key: "g", desc: "first"),
        disabled: true
      )
      @goto_last = Bubbles::Key::Binding.new(
        keys: ["G"],
        help: Bubbles::Key::Help.new(key: "G", desc: "last"),
        disabled: true
      )
      @page_up = Bubbles::Key::Binding.new(
        keys: ["K", "pgup"],
        help: Bubbles::Key::Help.new(key: "pgup", desc: "page up"),
        disabled: true
      )
      @page_down = Bubbles::Key::Binding.new(
        keys: ["J", "pgdown"],
        help: Bubbles::Key::Help.new(key: "pgdown", desc: "page down"),
        disabled: true
      )
      @back = Bubbles::Key::Binding.new(
        keys: ["h", "backspace", "left", "esc"],
        help: Bubbles::Key::Help.new(key: "h", desc: "back"),
        disabled: true
      )
      @select = Bubbles::Key::Binding.new(
        keys: ["enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "select"),
        disabled: true
      )
      @up = Bubbles::Key::Binding.new(
        keys: ["up", "k", "ctrl+k", "ctrl+p"],
        help: Bubbles::Key::Help.new(key: "↑", desc: "up"),
        disabled: true
      )
      @down = Bubbles::Key::Binding.new(
        keys: ["down", "j", "ctrl+j", "ctrl+n"],
        help: Bubbles::Key::Help.new(key: "↓", desc: "down"),
        disabled: true
      )
      @open = Bubbles::Key::Binding.new(
        keys: ["l", "right", "enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "open")
      )
      @close = Bubbles::Key::Binding.new(
        keys: ["esc"],
        help: Bubbles::Key::Help.new(key: "esc", desc: "close"),
        disabled: true
      )
      @prev = Bubbles::Key::Binding.new(
        keys: ["shift+tab"],
        help: Bubbles::Key::Help.new(key: "shift+tab", desc: "back")
      )
      @next = Bubbles::Key::Binding.new(
        keys: ["tab"],
        help: Bubbles::Key::Help.new(key: "tab", desc: "next")
      )
      @submit = Bubbles::Key::Binding.new(
        keys: ["enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "submit")
      )
    end
  end

  # NoteKeyMap is the keybindings for note fields.
  class NoteKeyMap
    property next : Bubbles::Key::Binding
    property prev : Bubbles::Key::Binding
    property submit : Bubbles::Key::Binding

    def initialize
      @prev = Bubbles::Key::Binding.new(
        keys: ["shift+tab"],
        help: Bubbles::Key::Help.new(key: "shift+tab", desc: "back")
      )
      @next = Bubbles::Key::Binding.new(
        keys: ["tab", "enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "next")
      )
      @submit = Bubbles::Key::Binding.new(
        keys: ["enter"],
        help: Bubbles::Key::Help.new(key: "enter", desc: "submit")
      )
    end
  end

  # NewDefaultKeyMap returns a new default keymap (Go-compatible API)
  def self.new_default_keymap : KeyMap
    KeyMap.new
  end

  # Default keymap instance
  DEFAULT_KEYMAP = KeyMap.new
end
