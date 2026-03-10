require "./spinner/spinner"

module Huh
  # Spinner provides a simple loading spinner for indicating background activity.
  #
  # ## Example
  #
  # ```
  # # Simple spinner with action
  # Huh::Spinner.new
  #   .title("Processing...")
  #   .action do
  #     sleep 2.seconds
  #     puts "Done!"
  #   end
  #   .run
  #
  # # Spinner with context (for cancellation)
  # ctx = Channel::Context.new
  # spawn do
  #   sleep 2.seconds
  #   ctx.close
  # end
  #
  # Huh::Spinner.new
  #   .title("Working...")
  #   .context(ctx)
  #   .run
  # ```
  #
  # ## Spinner Types
  #
  # - `Huh::Spinner::Line` - Simple line spinner (|, /, -, \)
  # - `Huh::Spinner::Dot` - Dot spinner (default)
  # - `Huh::Spinner::MiniDot` - Small dot spinner
  # - `Huh::Spinner::Jump` - Jumping character
  # - `Huh::Spinner::Points` - Moving points
  # - `Huh::Spinner::Pulse` - Pulsing blocks
  # - `Huh::Spinner::Globe` - Rotating globe emoji
  # - `Huh::Spinner::Moon` - Moon phases
  # - `Huh::Spinner::Monkey` - Monkey emojis
  # - `Huh::Spinner::Meter` - Progress meter
  # - `Huh::Spinner::Hamburger` - Hamburger menu
  # - `Huh::Spinner::Ellipsis` - Ellipsis animation
  #
  alias Spinner = Spinner::Spinner
end
