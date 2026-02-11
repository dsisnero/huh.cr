module GoldenHelper
  # Path to the testdata directory
  TESTDATA_PATH = File.join(__DIR__, "..", "testdata")

  # Read a golden file from testdata/go directory
  def self.read_golden(filename : String) : String
    path = File.join(TESTDATA_PATH, "go", filename)
    File.read(path)
  end

  # Compare actual output with golden file
  def self.compare(actual : String, golden_filename : String) : Bool
    expected = read_golden(golden_filename)
    
    if actual == expected
      true
    else
      # Output diff for debugging
      puts "Golden file mismatch for #{golden_filename}"
      puts "Expected (#{expected.bytesize} bytes):"
      puts expected.inspect
      puts "\nActual (#{actual.bytesize} bytes):"
      puts actual.inspect
      
      # Show character-by-character comparison for small strings
      if expected.size < 100 && actual.size < 100
        puts "\nCharacter comparison:"
        expected.chars.each_with_index do |char, i|
          if i >= actual.size
            puts "Position #{i}: Expected '#{char.inspect}' (##{char.ord}), got EOF"
          elsif char != actual[i]
            puts "Position #{i}: Expected '#{char.inspect}' (##{char.ord}), got '#{actual[i].inspect}' (##{actual[i].ord})"
          end
        end
        if actual.size > expected.size
          (expected.size...actual.size).each do |i|
            puts "Position #{i}: Expected EOF, got '#{actual[i].inspect}' (##{actual[i].ord})"
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