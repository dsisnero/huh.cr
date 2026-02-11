require "ansi"

module GoldenHelper
  # Path to the testdata directory
  TESTDATA_PATH = File.join(__DIR__, "..", "testdata")

  # Read a golden file from testdata/go directory
  def self.read_golden(filename : String) : String
    path = File.join(TESTDATA_PATH, "go", filename)
    File.read(path)
  end

  # Strip ANSI escape sequences from string
  def self.strip_ansi(str : String) : String
    Ansi.strip(str)
  end

  # Compare actual output with golden file
  def self.compare(actual : String, golden_filename : String) : Bool
    expected = read_golden(golden_filename)
    stripped_actual = strip_ansi(actual)

    if stripped_actual == expected
      true
    else
      # Output diff for debugging
      puts "Golden file mismatch for #{golden_filename}"
      puts "Expected (#{expected.bytesize} bytes):"
      puts expected.inspect
      puts "\nActual stripped (#{stripped_actual.bytesize} bytes):"
      puts stripped_actual.inspect
      puts "\nActual raw (#{actual.bytesize} bytes):"
      puts actual.inspect

      # Show character-by-character comparison for small strings
      if expected.size < 100 && stripped_actual.size < 100
        puts "\nCharacter comparison (stripped):"
        expected.chars.each_with_index do |char, i|
          if i >= stripped_actual.size
            puts "Position #{i}: Expected '#{char.inspect}' (##{char.ord}), got EOF"
          elsif char != stripped_actual[i]
            puts "Position #{i}: Expected '#{char.inspect}' (##{char.ord}), got '#{stripped_actual[i].inspect}' (##{stripped_actual[i].ord})"
          end
        end
        if stripped_actual.size > expected.size
          (expected.size...stripped_actual.size).each do |i|
            puts "Position #{i}: Expected EOF, got '#{stripped_actual[i].inspect}' (##{stripped_actual[i].ord})"
          end
        end
      end

      false
    end
  end

  # Assert that actual output matches golden file
  def self.assert_matches(actual : String, golden_filename : String, file = __FILE__, line = __LINE__)
    unless compare(actual, golden_filename)
      fail "Output does not match golden file #{golden_filename}", file, line
    end
  end
end
