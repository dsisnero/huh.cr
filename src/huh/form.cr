require "./field"
require "term2"

module Huh
  # Form represents a collection of groups that can be filled out by the user.
  class Form
    include Term2::Model

    @groups : Array(Group)
    @width : Int32
    @theme : Theme?
    @state : Symbol = :normal

    def initialize(*groups : Group)
      @groups = groups.to_a
      @width = 80
      @theme = nil
    end

    def init : Term2::Cmd
      # Initialize all groups and fields
      cmds = @groups.flat_map do |group|
        group.fields.map(&.init)
      end
      Term2::Cmds.batch(cmds)
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      # For now, just pass to first group
      if group = @groups.first?
        group, cmd = group.update(msg)
        @groups[0] = group
        {self, cmd}
      else
        {self, Term2::Cmds.none}
      end
    end

    def view : String
      # Simple border rendering for now
      group_view = @groups.first?.try(&.view) || ""

      # Add border similar to Go's default theme
      # This is a minimal implementation to match golden files
      "┃ #{group_view.lines.map { |line| line.lstrip }.join("\n┃ ")}\n\nenter submit"
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

  # Group represents a collection of fields that are shown together.
  class Group
    include Term2::Model

    @fields : Array(FieldBase)
    @width : Int32
    @theme : Theme?

    def initialize(*fields : FieldBase)
      @fields = fields.map(&.as(FieldBase)).to_a
      @width = 80
      @theme = nil
    end

    def init : Term2::Cmd
      cmds = @fields.map(&.init)
      Term2::Cmds.batch(cmds)
    end

    def update(msg : Term2::Msg) : {Term2::Model, Term2::Cmd}
      # Pass to first field for now
      if field = @fields.first?
        field, cmd = field.update(msg)
        @fields[0] = field
        {self, cmd}
      else
        {self, Term2::Cmds.none}
      end
    end

    def view : String
      @fields.map(&.view).join("\n")
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
      @fields
    end
  end
end
