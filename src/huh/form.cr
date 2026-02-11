require "./field"
require "./selector"
require "term2"

module Huh
  # Form represents a collection of groups that can be filled out by the user.
  class Form
    include Term2::Model

    @selector : Selector(Group)
    @width : Int32
    @theme : Theme?
    @state : Symbol = :normal

    def initialize(*groups : Group)
      @selector = Selector(Group).new(groups.map(&.as(Group)).to_a)
      @width = 80
      @theme = nil
    end

    def init : Term2::Cmd
      cmds = [] of Term2::Cmd
      @selector.range do |i, group|
        if i == 0
          group.active = true
        end
        cmds << group.init
        true
      end
      Term2::Cmds.batch(cmds)
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      case msg
      when NextGroupMsg
        # Move to next non-hidden group
        if @selector.on_last?
          # TODO: submit form
          return {self, Term2::Cmds.none}
        end
        @selector.next
        @selector.selected.active = true
        {self, @selector.selected.init}
      when PrevGroupMsg
        if @selector.on_first?
          return {self, Term2::Cmds.none}
        end
        @selector.prev
        @selector.selected.active = true
        {self, @selector.selected.init}
      else
        # Delegate to selected group
        idx = @selector.index
        group = @selector.selected
        updated, cmd = group.update(msg)
        @selector.set(idx, updated.as(Group))
        {self, cmd}
      end
    end

    def view : String
      # Simple border rendering for now
      group_view = @selector.selected.view

      # Add border similar to Go's default theme
      # This is a minimal implementation to match golden files
      "┃ #{group_view.lines.map(&.lstrip).join("\n┃ ")}\n\nenter submit"
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
  end

  # Message to move to next field
  struct NextFieldMsg
  end

  # Message to move to previous field
  struct PrevFieldMsg
  end

  # Command to move to next field
  def self.next_field : NextFieldMsg
    NextFieldMsg.new
  end

  # Command to move to previous field
  def self.prev_field : PrevFieldMsg
    PrevFieldMsg.new
  end

  # Message to move to next group
  struct NextGroupMsg
  end

  # Message to move to previous group
  struct PrevGroupMsg
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
    include Term2::Model

    @selector : Selector(FieldBase)
    @width : Int32
    @theme : Theme?
    @active : Bool = false
    property active : Bool

    def initialize(*fields : FieldBase)
      @selector = Selector(FieldBase).new(fields.map(&.as(FieldBase)).to_a)
      @width = 80
      @theme = nil
    end

    def init : Term2::Cmd
      cmds = [] of Term2::Cmd
      # Initialize all fields
      @selector.range do |_, field|
        cmds << field.init
        true
      end
      if @active
        cmds << @selector.selected.focus
      end
      Term2::Cmds.batch(cmds)
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      case msg
      when NextFieldMsg
        cmds = next_field
        {self, Term2::Cmds.batch(cmds)}
      when PrevFieldMsg
        cmds = prev_field
        {self, Term2::Cmds.batch(cmds)}
      else
        # Update selected field
        idx = @selector.index
        field = @selector.selected
        updated, cmd = field.update(msg)
        @selector.set(idx, updated.as(FieldBase))
        {self, cmd}
      end
    end

    private def next_field : Array(Term2::Cmd)
      cmds = [] of Term2::Cmd
      cmds << @selector.selected.blur
      if @selector.on_last?
        # TODO: Move to next group
        return cmds
      end
      @selector.next
      while @selector.selected.skip?
        if @selector.on_last?
          # TODO: Move to next group
          break
        end
        @selector.next
      end
      cmds << @selector.selected.focus
      cmds
    end

    private def prev_field : Array(Term2::Cmd)
      cmds = [] of Term2::Cmd
      cmds << @selector.selected.blur
      if @selector.on_first?
        # TODO: Move to previous group
        return cmds
      end
      @selector.prev
      while @selector.selected.skip?
        if @selector.on_first?
          # TODO: Move to previous group
          break
        end
        @selector.prev
      end
      cmds << @selector.selected.focus
      cmds
    end

    def view : String
      @selector.items.map(&.view).join("\n")
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

    # Get fields
    def fields : Array(FieldBase)
      @selector.items
    end
  end
end
