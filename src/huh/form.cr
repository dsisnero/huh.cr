require "./field"
require "./selector"
require "./layout"

module Huh
  # Form represents a collection of groups that can be filled out by the user.
  #
  # Forms are composed of groups, which are composed of fields. Each group
  # represents a logical section or "page" of the form.
  #
  # ## Example
  #
  # ```
  # form = Huh.new_form(
  #   Huh.new_group(
  #     Huh.new_input.title("Name"),
  #     Huh.new_input.title("Email")
  #   ),
  #   Huh.new_group(
  #     Huh.new_confirm.title("Subscribe to newsletter?")
  #   )
  # )
  #
  # form.run
  # ```
  #
  # ## Navigation
  #
  # Users navigate between groups using Tab/Shift+Tab or arrow keys.
  # Each group can contain multiple fields that are navigated with Tab/Shift+Tab.
  #
  class Form
    @selector : Selector(Group)
    @width : Int32
    @theme : Theme?
    @accessible : Bool = false
    @state : Symbol = :normal
    @layout : Layout::LayoutBase = Layout::LAYOUT_DEFAULT
    @timeout : Time::Span = 0.seconds

    # Creates a new form with the given groups.
    #
    # ```
    # form = Huh::Form.new(
    #   Huh::Group.new(field1, field2),
    #   Huh::Group.new(field3)
    # )
    # ```
    def initialize(*groups : Group)
      @selector = Selector(Group).new(groups.map(&.as(Group)).to_a)
      @width = 80
      @theme = nil
      @layout = Layout::LAYOUT_DEFAULT
    end

    def init : Tea::Cmd?
      cmds = [] of Tea::Cmd?
      first_visible_group = find_next_visible_group(0)
      @selector.range do |i, group|
        group.active = (i == first_visible_group)
        cmds << group.init
        true
      end
      # Update field positions before initializing
      update_field_positions
      if first_visible_group >= 0
        @selector.set_index(first_visible_group)
      end
      Tea.batch(cmds)
    end

    # UpdateFieldPositions sets the position on all the fields.
    def update_field_positions : self
      first_group = 0
      last_group = @selector.total - 1

      @selector.range do |_, group|
        if !group_hidden?(group)
          next false
        end
        first_group += 1
        true
      end

      @selector.reverse_range do |_, group|
        if !group_hidden?(group)
          next false
        end
        last_group -= 1
        true
      end

      @selector.range do |group_index, group|
        # Determine first non-skippable field
        first_field = 0
        group.selector.range do |_, field|
          if !field.skip || group.selector.total == 1
            next false # break from loop
          end
          first_field += 1
          true
        end

        # Determine last non-skippable field
        last_field = group.selector.total - 1
        group.selector.reverse_range do |i, field|
          last_field = i
          if !field.skip || group.selector.total == 1
            next false # break from loop
          end
          true
        end

        # Set position on all fields
        group.selector.range do |i, field|
          field.with_position(FieldPosition.new(
            group: group_index,
            field: i,
            first_field: i == first_field,
            last_field: i == last_field,
            first_group: group_index == first_group,
            last_group: group_index == last_group
          ))
          true
        end
        true
      end

      self
    end

    def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
      case msg
      when NextGroupMsg
        if (next_visible = find_next_visible_group(@selector.index + 1)) < 0
          @state = :completed
          return {self, Tea.quit}
        end
        @selector.set_index(next_visible)
        @selector.selected.active = true
        {self, @selector.selected.init}
      when PrevGroupMsg
        if (prev_visible = find_prev_visible_group(@selector.index - 1)) < 0
          return {self, nil}
        end
        @selector.set_index(prev_visible)
        @selector.selected.active = true
        {self, @selector.selected.init}
      else
        # Delegate to selected group
        idx = @selector.index
        group = @selector.selected
        updated, cmd = group.update(msg)
        @selector.set(idx, updated.as(Group))

        if msg.is_a?(Tea::KeyPressMsg)
          update_field_positions
          if group_hidden?(@selector.selected)
            if (next_visible = find_next_visible_group(@selector.index + 1)) >= 0
              @selector.set_index(next_visible)
              @selector.selected.active = true
              return {self, @selector.selected.init}
            elsif (prev_visible = find_prev_visible_group(@selector.index - 1)) >= 0
              @selector.set_index(prev_visible)
              @selector.selected.active = true
              return {self, @selector.selected.init}
            else
              @state = :completed
              return {self, Tea.quit}
            end
          end
        end

        {self, cmd}
      end
    end

    def view : String
      # Use layout to render form (matches Go form.View() which calls f.layout.View(f))
      @layout.view(self)
    end

    # Fluent configuration
    def with_width(width : Int32) : self
      @width = width
      self
    end

    def with_theme(theme : Theme) : self
      @theme = theme
      self
    end

    def with_layout(layout : Layout::LayoutBase) : self
      @layout = layout
      self
    end

    def with_timeout(timeout : Time::Span) : self
      @timeout = timeout
      self
    end

    # Getter for selector
    def selector : Selector(Group)
      @selector
    end

    # Run runs the form as a standalone program.
    def run : Nil
      if @accessible
        if @timeout > 0.seconds
          raise Huh::TimeoutUnsupportedError.new("timeout is not supported in accessible mode")
        end
        run_accessible
        return
      end

      options = [] of Tea::ProgramOption
      ctx = nil.as(Tea::ExecutionContext?)
      if @timeout > 0.seconds
        context = Tea::ExecutionContext.new
        ctx = context
        options << Tea.with_context(context)
      end

      program = Tea::Program.new(Huh::RuntimeModel(Form).new(self))
      options.each(&.call(program))

      if context = ctx
        spawn do
          sleep @timeout
          context.cancel
        end
      end

      _model, err = program.run
      return unless err

      case err
      when Tea::InterruptedError
        raise Huh::UserAbortedError.new("user aborted")
      when Tea::ProgramKilledError
        raise Huh::TimeoutError.new("timeout")
      else
        raise err
      end
    end

    # WithAccessible runs the form using accessible prompt mode.
    def with_accessible(accessible : Bool) : self
      @accessible = accessible
      self
    end

    # RunAccessible runs the form in accessible mode (non-interactive).
    def run_accessible : Nil
      first_visible_group = find_next_visible_group(0)
      @selector.range do |i, group|
        group.active = (i == first_visible_group)
        unless group_hidden?(group)
          group.run_accessible(STDOUT, STDIN)
        end
        true
      end
    end

    private def group_hidden?(group : Group) : Bool
      group.hidden?
    end

    private def find_next_visible_group(start_index : Int32) : Int32
      i = start_index
      while i < @selector.total
        return i unless group_hidden?(@selector.get(i))
        i += 1
      end
      -1
    end

    private def find_prev_visible_group(start_index : Int32) : Int32
      i = start_index
      while i >= 0
        return i unless group_hidden?(@selector.get(i))
        i -= 1
      end
      -1
    end
  end

  # Message to move to next field
  struct NextFieldMsg
    include ::Tea::Msg
  end

  # Message to move to previous field
  struct PrevFieldMsg
    include ::Tea::Msg
  end

  # Command to move to next field
  def self.next_field : NextFieldMsg
    NextFieldMsg.new
  end

  # Command to move to previous field
  def self.prev_field : PrevFieldMsg
    PrevFieldMsg.new
  end

  # Message to trigger dynamic field reevaluation in the active group.
  struct UpdateFieldMsg
    include ::Tea::Msg
  end

  def self.update_field : UpdateFieldMsg
    UpdateFieldMsg.new
  end

  # Message to move to next group
  struct NextGroupMsg
    include ::Tea::Msg
  end

  # Message to move to previous group
  struct PrevGroupMsg
    include ::Tea::Msg
  end

  # Command to move to next group
  def self.next_group : NextGroupMsg
    NextGroupMsg.new
  end

  # Command to move to previous group
  def self.prev_group : PrevGroupMsg
    PrevGroupMsg.new
  end

  # Group represents a collection of fields that are shown together.
  class Group
    @selector : Selector(FieldBase)
    @width : Int32
    @theme : Theme?
    @active : Bool = false
    @help : Bubbles::Help::Model
    @hide : Proc(Bool)?
    property? active : Bool

    def initialize(*fields : FieldBase)
      @selector = Selector(FieldBase).new(fields.map(&.as(FieldBase)).to_a)
      @width = 80
      @theme = nil
      @help = Bubbles::Help::Model.new
      @hide = nil
      # Propagate default width to all fields
      @selector.items.each do |field|
        field.with_width(@width)
      end
    end

    def init : Tea::Cmd?
      cmds = [] of Tea::Cmd?
      # Initialize all fields
      @selector.range do |_, field|
        cmds << field.init
        true
      end

      if @selector.selected.skip
        if @selector.on_last?
          return Tea.batch(prev_field)
        elsif @selector.on_first?
          return Tea.batch(next_field)
        end
      end

      if @active
        cmds << @selector.selected.focus
      end
      Tea.batch(cmds)
    end

    def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
      cmds = [] of Tea::Cmd?

      case msg
      when NextFieldMsg
        cmds = next_field
        {self, Tea.batch(cmds)}
      when PrevFieldMsg
        cmds = prev_field
        {self, Tea.batch(cmds)}
      else
        selected_index = @selector.index
        keypress = msg.is_a?(Tea::KeyPressMsg)

        @selector.range do |index, field|
          current = field

          # Match upstream behavior: selected field receives key messages,
          # all fields receive non-key messages.
          if !keypress || index == selected_index
            updated, cmd = current.update(msg)
            current = updated.as(FieldBase)
            @selector.set(index, current)
            cmds << cmd
          end

          # All fields reevaluate dynamic funcs after each update cycle.
          reevaluated, reevaluate_cmd = current.update(Huh.update_field)
          @selector.set(index, reevaluated.as(FieldBase))
          cmds << reevaluate_cmd
          true
        end

        {self, Tea.batch(cmds)}
      end
    end

    private def next_field : Array(Tea::Cmd?)
      cmds = [] of Tea::Cmd?
      cmds << @selector.selected.blur
      if @selector.on_last?
        cmds << (-> : ::Tea::Msg? { Huh.next_group })
        return cmds
      end
      @selector.next
      while @selector.selected.skip
        if @selector.on_last?
          cmds << (-> : ::Tea::Msg? { Huh.next_group })
          break
        end
        @selector.next
      end
      cmds << @selector.selected.focus
      cmds
    end

    private def prev_field : Array(Tea::Cmd?)
      cmds = [] of Tea::Cmd?
      cmds << @selector.selected.blur
      if @selector.on_first?
        cmds << (-> : ::Tea::Msg? { Huh.prev_group })
        return cmds
      end
      @selector.prev
      while @selector.selected.skip
        if @selector.on_first?
          cmds << (-> : ::Tea::Msg? { Huh.prev_group })
          break
        end
        @selector.prev
      end
      cmds << @selector.selected.focus
      cmds
    end

    def view : String
      # Match Go Group.View() which returns content + footer
      content + footer
    end

    # Content returns the rendered content of the group without borders.
    def content : String
      # Match Go viewport rendering: trailing spacer row at group width before footer/help.
      @selector.items.map(&.view).join("\n") + "\n" + (" " * @width)
    end

    # Footer returns the footer text for the group.
    def footer : String
      # Start with newline like Go's Footer() method
      String.build do |str|
        str << '\n'

        # Get help text from field's key bindings
        field = @selector.selected.as(Huh::FieldBase)
        huh_bindings = field.key_binds
        # Convert Huh KeyBinding to Bubbles Key::Binding
        bubbles_bindings = huh_bindings.map do |binding|
          # Map key names to display symbols (matching Go behavior)
          display_key = case binding.action
                        when :up
                          "↑"
                        when :down
                          "↓"
                        when :toggle
                          "←/→"
                        when :filter
                          "/"
                        when :submit
                          "enter"
                        when :accept
                          "y"
                        when :reject
                          "n"
                        else
                          binding.keys.first? || ""
                        end

          Bubbles::Key::Binding.new(
            keys: binding.keys,
            help: Bubbles::Key::Help.new(
              key: display_key,
              desc: binding.help
            )
          )
        end
        str << @help.short_help_view(bubbles_bindings)

        # TODO: Add error display like Go's Footer() when showErrors is true
      end
    end

    # Getter for selector
    def selector : Selector(FieldBase)
      @selector
    end

    # Getter for help model
    def help : Bubbles::Help::Model
      @help
    end

    # Fluent configuration
    def with_width(width : Int32) : self
      @width = width
      self
    end

    def with_theme(theme : Theme) : self
      @theme = theme
      self
    end

    def hide(hidden : Bool) : self
      @hide = -> { hidden }
      self
    end

    def hide_func(&block : -> Bool) : self
      @hide = block
      self
    end

    def hidden? : Bool
      if hide = @hide
        hide.call
      else
        false
      end
    end

    # RunAccessible runs the group in accessible mode.
    def run_accessible(writer : IO, reader : IO) : Nil
      @selector.range do |_, field|
        field.run_accessible(writer, reader)
        true
      end
    end

    # Get fields
    def fields : Array(FieldBase)
      @selector.items
    end
  end
end
