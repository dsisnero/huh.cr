require "lipgloss"

module Huh
  module Layout
    # Layout constants
    LAYOUT_DEFAULT = LayoutDefault.new
    LAYOUT_STACK   = LayoutStack.new

    # LayoutColumns creates a column layout with the given number of columns.
    def self.layout_columns(columns : Int32) : LayoutBase
      LayoutColumns.new(columns)
    end

    # LayoutGrid creates a grid layout with the given number of rows and columns.
    def self.layout_grid(rows : Int32, columns : Int32) : LayoutBase
      LayoutGrid.new(rows, columns)
    end

    # A Layout is responsible for laying out groups in a form.
    abstract class LayoutBase
      abstract def view(form : Form) : String
      abstract def group_width(form : Form, group : Group, width : Int32) : Int32
    end

    # Default layout shows a single group at a time.
    class LayoutDefault < LayoutBase
      def view(form : Form) : String
        form.selector.selected.view
      end

      def group_width(form : Form, group : Group, width : Int32) : Int32
        width
      end
    end

    # Stack layout stacks all groups on top of each other.
    class LayoutStack < LayoutBase
      def view(form : Form) : String
        columns = [] of String
        form.selector.range do |_, group|
          unless group.hidden?
            columns << group.content
          end
          true
        end
        footer = form.selector.selected.footer
        columns.join("\n") + footer
      end

      def group_width(form : Form, group : Group, width : Int32) : Int32
        width
      end
    end

    # Column layout distributes groups in even columns.
    class LayoutColumns < LayoutBase
      @columns : Int32

      def initialize(@columns : Int32)
      end

      private def visible_groups(form : Form) : Array(Group)
        groups = Layout.rendered_groups(form)
        return [] of Group if groups.empty?

        selected_visible_index = Layout.rendered_index_for_selected(form, groups)
        segment_index = selected_visible_index // @columns
        start_idx = segment_index * @columns
        end_idx = start_idx + @columns

        total = groups.size
        end_idx = total if end_idx > total

        groups[start_idx...end_idx]
      end

      def view(form : Form) : String
        groups = visible_groups(form)
        return "" if groups.empty?

        columns = groups.map(&.content)
        footer = form.selector.selected.footer
        Lipgloss.join_vertical(Lipgloss::Position::Left,
          Lipgloss.join_horizontal(Lipgloss::Position::Top, columns),
          footer
        )
      end

      def group_width(form : Form, group : Group, width : Int32) : Int32
        width // @columns
      end
    end

    # Grid layout distributes groups in a grid.
    class LayoutGrid < LayoutBase
      @rows : Int32
      @columns : Int32

      def initialize(@rows : Int32, @columns : Int32)
      end

      private def visible_groups(form : Form) : Array(Array(Group))
        groups = Layout.rendered_groups(form)
        return [] of Array(Group) if groups.empty?

        total = @rows * @columns
        selected_visible_index = Layout.rendered_index_for_selected(form, groups)
        segment_index = selected_visible_index // total
        start_idx = segment_index * total
        end_idx = start_idx + total

        end_idx = groups.size if end_idx > groups.size
        visible = groups[start_idx...end_idx]

        grid = Array(Array(Group)).new(@rows) { [] of Group }
        @rows.times do |i|
          start_row = i * @columns
          end_row = start_row + @columns
          break if start_row >= visible.size
          end_row = visible.size if end_row > visible.size
          grid[i] = visible[start_row...end_row]
        end
        grid
      end

      def view(form : Form) : String
        grid = visible_groups(form)
        return "" if grid.empty?

        rows = [] of String
        grid.each do |row|
          columns = [] of String
          row.each do |group|
            columns << group.content
          end
          rows << Lipgloss.join_horizontal(Lipgloss::Position::Top, columns)
        end
        footer = form.selector.selected.footer
        Lipgloss.join_vertical(Lipgloss::Position::Left,
          rows.join("\n"),
          footer
        )
      end

      def group_width(form : Form, group : Group, width : Int32) : Int32
        width // @columns
      end
    end

    def self.rendered_groups(form : Form) : Array(Group)
      groups = [] of Group
      form.selector.range do |_, group|
        groups << group unless group.hidden?
        true
      end
      groups
    end

    def self.rendered_index_for_selected(form : Form, groups : Array(Group)) : Int32
      selected = form.selector.selected
      idx = groups.index(selected)
      idx || 0
    end
  end
end
