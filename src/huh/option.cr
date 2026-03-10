module Huh
  # Option is an option for select fields.
  class Option(T)
    property key : String
    property value : T
    property? selected : Bool = false

    # Creates a new select option
    def initialize(@key : String, @value : T, @selected : Bool = false)
    end

    # Selected sets whether the option is currently selected
    def selected(selected : Bool) : Option(T)
      @selected = selected
      self
    end

    # Returns the key of the option
    def to_s : String
      @key
    end
  end

  # Helper functions for creating options

  # NewOption returns a new select option
  def self.new_option(key : String, value : T) : Option(T) forall T
    Option(T).new(key, value)
  end

  # NewOptions returns new options from a list of values
  def self.new_options(values : Array(T)) : Array(Option(T)) forall T
    values.map { |v| Option(T).new(v.to_s, v) }
  end

  # NewOptions returns new options from varargs
  def self.new_options(*values : T) : Array(Option(T)) forall T
    values.map { |v| Option(T).new(v.to_s, v) }.to_a
  end
end
