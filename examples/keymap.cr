require "../src/huh"

# Example demonstrating custom keymaps in Huh

puts "=== Huh Custom KeyMap Example ==="
puts "This example shows how to customize key bindings in Huh forms.\n"

# Create a custom keymap
custom_keymap = Huh::KeyMap.new

# Customize input field key bindings
custom_keymap.input.next.set_keys("ctrl+n", "->") # Change Next key
custom_keymap.input.next.set_help("ctrl+n", "go forward")
custom_keymap.input.prev.set_keys("ctrl+p", "<-") # Change Prev key
custom_keymap.input.prev.set_help("ctrl+p", "go back")
custom_keymap.input.submit.set_keys("ctrl+s") # Change Submit key
custom_keymap.input.submit.set_help("ctrl+s", "submit form")

# Customize confirm field key bindings
custom_keymap.confirm.toggle.set_keys("t", "T") # Change Toggle key
custom_keymap.confirm.toggle.set_help("t", "toggle yes/no")
custom_keymap.confirm.accept.set_keys("1") # Change Accept key
custom_keymap.confirm.accept.set_help("1", "yes")
custom_keymap.confirm.reject.set_keys("0") # Change Reject key
custom_keymap.confirm.reject.set_help("0", "no")

# Create a form with custom keymap
name = Huh.cell("")
subscribe = Huh.cell(false)

form = Huh.new_form(
  Huh.new_group(
    Huh.new_input
      .title("What's your name?")
      .placeholder("Enter your name")
      .value(name)
      .with_keymap(custom_keymap),

    Huh.new_confirm
      .title("Subscribe to newsletter?")
      .affirmative("Yes, please!")
      .negative("No, thanks")
      .value(subscribe)
      .with_key_map(custom_keymap)
  )
)

puts "Form created with custom keymap:"
puts "- Input Next: #{custom_keymap.input.next.keys.try(&.join(", ")) || "none"} (#{custom_keymap.input.next.help.desc})"
puts "- Input Prev: #{custom_keymap.input.prev.keys.try(&.join(", ")) || "none"} (#{custom_keymap.input.prev.help.desc})"
puts "- Input Submit: #{custom_keymap.input.submit.keys.try(&.join(", ")) || "none"} (#{custom_keymap.input.submit.help.desc})"
puts "- Confirm Toggle: #{custom_keymap.confirm.toggle.keys.try(&.join(", ")) || "none"} (#{custom_keymap.confirm.toggle.help.desc})"
puts "- Confirm Accept: #{custom_keymap.confirm.accept.keys.try(&.join(", ")) || "none"} (#{custom_keymap.confirm.accept.help.desc})"
puts "- Confirm Reject: #{custom_keymap.confirm.reject.keys.try(&.join(", ")) || "none"} (#{custom_keymap.confirm.reject.help.desc})"

puts "\nDefault quit key (still works): #{custom_keymap.quit.keys.try(&.join(", ")) || "none"}"

puts "\n=== Example Complete ==="
puts "This form would use the custom key bindings when run."
puts "Note: Actually running the form requires a terminal UI."
