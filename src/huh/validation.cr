require "set"

module Huh
  def self.validate_not_empty : Proc(String, Exception | Nil)
    validator = validate_min_length(1)
    ->(s : String) do
      if validator.call(s)
        Exception.new("input cannot be empty")
      else
        nil
      end
    end
  end

  def self.validate_min_length(v : Int32) : Proc(String, Exception | Nil)
    ->(s : String) do
      if s.size < v
        Exception.new("input must be at least #{v} characters long")
      else
        nil
      end
    end
  end

  def self.validate_max_length(v : Int32) : Proc(String, Exception | Nil)
    ->(s : String) do
      if s.size > v
        Exception.new("input must be at most #{v} characters long")
      else
        nil
      end
    end
  end

  def self.validate_length(min_length : Int32, max_length : Int32) : Proc(String, Exception | Nil)
    min = validate_min_length(min_length)
    max = validate_max_length(max_length)
    ->(s : String) do
      if err = min.call(s)
        err
      else
        max.call(s)
      end
    end
  end

  def self.validate_one_of(*options : String) : Proc(String, Exception | Nil)
    valid = options.to_set
    ->(value : String) do
      unless valid.includes?(value)
        Exception.new("invalid option: #{value}")
      end
    end
  end
end
