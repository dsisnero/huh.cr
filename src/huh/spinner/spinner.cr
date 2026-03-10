require "bubbles"
require "lipgloss"

module Huh
  module Spinner
    # Type alias for Bubbles spinner types
    alias Type = Bubbles::Spinner::Spinner

    # Spinner types matching Go Huh
    Line      = Bubbles::Spinner::Line
    Dot       = Bubbles::Spinner::Dot
    MiniDot   = Bubbles::Spinner::MiniDot
    Jump      = Bubbles::Spinner::Jump
    Points    = Bubbles::Spinner::Points
    Pulse     = Bubbles::Spinner::Pulse
    Globe     = Bubbles::Spinner::Globe
    Moon      = Bubbles::Spinner::Moon
    Monkey    = Bubbles::Spinner::Monkey
    Meter     = Bubbles::Spinner::Meter
    Hamburger = Bubbles::Spinner::Hamburger
    Ellipsis  = Bubbles::Spinner::Ellipsis

    # Spinner represents a loading spinner for indicating background activity.
    class Spinner
      @spinner : Bubbles::Spinner::Model
      @action : Proc(Nil)?
      @title : String = "Loading..."
      @title_style : Lipgloss::Style
      @accessible : Bool = false
      @done : Bool = false

      # Creates a new spinner.
      def initialize
        @spinner = Bubbles::Spinner::Model.new
        @spinner.spinner = Dot
        @spinner.style = Lipgloss::Style.new.foreground("#F780E2")
        @title_style = Lipgloss::Style.new
      end

      # Type sets the spinner type.
      def type(type : Type) : self
        @spinner.spinner = type
        self
      end

      # Title sets the spinner title.
      def title(title : String) : self
        @title = title
        self
      end

      # Action sets the action to run while showing spinner.
      def action(&block : ->) : self
        @action = block
        self
      end

      # Style sets the spinner style.
      def style(style : Lipgloss::Style) : self
        @spinner.style = style
        self
      end

      # TitleStyle sets the title style.
      def title_style(style : Lipgloss::Style) : self
        @title_style = style
        self
      end

      # Accessible sets accessible mode (shows static text instead of animation).
      def accessible(accessible : Bool) : self
        @accessible = accessible
        self
      end

      # Run runs the spinner.
      def run : Nil
        if @accessible
          run_accessible
        else
          run_interactive
        end
      end

      # Tea::Model implementation
      def init : Tea::Cmd?
        if @action
          # Start action in background
          spawn do
            begin
              @action.try(&.call)
            ensure
              @done = true
            end
          end
        end

        # Start spinner ticks
        -> : ::Tea::Msg? { @spinner.tick }
      end

      def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
        case msg
        when Tea::KeyPressMsg
          if msg.string == "ctrl+c"
            @done = true
            return {self, Tea.quit}
          end
        end

        # Update internal spinner
        spinner, cmd = @spinner.update(msg)
        @spinner = spinner.as(Bubbles::Spinner::Model)

        # Check if done
        if @done
          return {self, Tea.quit}
        end

        {self, cmd}
      end

      def view : String
        if @accessible
          return @title_style.render(@title) unless @title.empty?
          return ""
        end

        io = IO::Memory.new
        io << @spinner.view
        if !@title.empty?
          io << " " << @title_style.render(@title)
        end
        io.to_s
      end

      private def run_interactive : Nil
        program = Tea::Program.new(Huh::RuntimeModel(Huh::Spinner::Spinner).new(self))
        _model, err = program.run
        raise err if err
      end

      private def run_accessible : Nil
        frame = @spinner.style.render("...")
        title_text = @title.ends_with?("...") ? @title.byte_slice(0, @title.bytesize - 3) : @title
        title = @title_style.render(title_text)
        STDOUT << title << frame << "\n"

        if @action
          @action.try(&.call)
        else
          # Just wait for Ctrl+C
          loop do
            sleep 100.milliseconds
          end
        end
      end
    end

    # New creates a new spinner.
    def self.new : Spinner
      Spinner.new
    end
  end
end
