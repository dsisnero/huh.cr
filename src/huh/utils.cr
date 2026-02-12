module Huh
  # Simple text wrapping utility
  def self.wrap(text : String, width : Int32) : String
    return text if width <= 0
    return text if text.size <= width

    result = String::Builder.new
    pos = 0
    while pos < text.size
      remaining = text.size - pos
      if remaining <= width
        result << text[pos..]
        break
      else
        # Try to break at word boundary
        break_pos = pos + width
        while break_pos > pos && !text[break_pos].ascii_whitespace?
          break_pos -= 1
        end
        if break_pos == pos
          # No whitespace found, force break
          break_pos = pos + width
        end
        result << text[pos...break_pos].strip
        result << "\n"
        pos = break_pos
        # Skip whitespace
        while pos < text.size && text[pos].ascii_whitespace?
          pos += 1
        end
      end
    end
    result.to_s
  end
end
