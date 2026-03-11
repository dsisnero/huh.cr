module Huh
  module Accessibility
    private def self.tty_reader?(reader : IO) : Bool
      fd_reader = reader.as?(IO::FileDescriptor)
      return false unless fd_reader
      LibC.isatty(fd_reader.fd) == 1
    end

    # PromptInt prompts a user for an integer between a certain range.
    #
    # Given invalid input (non-integers, integers outside of the range), the user
    # will continue to be reprompted until a valid input is given, ensuring that
    # the return value is always valid.
    def self.prompt_int(writer : IO, reader : IO, prompt : String, low : Int32, high : Int32) : Int32
      valid_int = ->(s : String) do
        begin
          i = s.to_i32
          if i >= low && i <= high
            nil
          else
            "invalid input. please try again"
          end
        rescue
          "invalid input. please try again"
        end
      end

      input = prompt_string(writer, reader, prompt, valid_int)
      input.to_i32
    end

    # PromptBool prompts a user for a boolean value.
    #
    # Given invalid input (non-boolean), the user will continue to be reprompted
    # until a valid input is given, ensuring that the return value is always valid.
    def self.prompt_bool(writer : IO, reader : IO, prompt : String = "Choose [y/N]: ") : Bool
      valid_bool = ->(s : String) do
        s = s.downcase
        if {"y", "yes"}.includes?(s)
          nil
        elsif {"n", "no"}.includes?(s)
          nil
        else
          "invalid input. please try again"
        end
      end

      input = prompt_string(writer, reader, prompt, valid_bool)
      input.downcase.in?("y", "yes")
    end

    # PromptString prompts a user for a string value and validates it against a
    # validator function. It re-prompts the user until a valid input is given.
    def self.prompt_string(writer : IO, reader : IO, prompt : String, validator : Proc(String, String?)) : String
      loop do
        writer << prompt
        writer.flush

        input = reader.gets
        unless input
          raise "EOF"
        end

        input = input.strip
        error = validator.call(input)
        unless error
          return input
        end

        writer << error << "\n"
      end
    end

    # PromptString prompts a user for a string value without validation.
    def self.prompt_string(writer : IO, reader : IO, prompt : String) : String
      prompt_string(writer, reader, prompt, ->(_s : String) { nil })
    end

    # PromptPassword prompts a password value in accessible mode.
    # This requires a TTY reader to preserve parity with Go behavior.
    def self.prompt_password(writer : IO, reader : IO, prompt : String, validator : Proc(String, String?)) : String
      raise "password prompt requires a tty reader" unless tty_reader?(reader)

      loop do
        writer << prompt
        writer.flush

        input = reader.gets
        raise "EOF" unless input

        trimmed = input.strip
        error = validator.call(trimmed)
        unless error
          return trimmed
        end

        writer << error << "\n"
      end
    end

    # ParseBool parses a string into a boolean value.
    #
    # Returns true for "y" or "yes", false for "n" or "no", and raises an error
    # for any other input.
    def self.parse_bool(s : String) : Bool
      s = s.downcase

      if {"y", "yes"}.includes?(s)
        return true
      elsif {"n", "no"}.includes?(s)
        return false
      end

      raise "invalid input. please try again"
    end
  end
end
