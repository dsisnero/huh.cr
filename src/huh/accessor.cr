# Accessor gives read/write access to field values.
module Huh
  # Accessor interface for typed value access
  module Accessor(T)
    abstract def get : T
    abstract def set(value : T) : Nil
  end

  # EmbeddedAccessor is a basic accessor, acting as the default one for fields.
  class EmbeddedAccessor(T)
    include Accessor(T)

    @value : T

    def initialize(@value : T)
    end

    # Gets the value
    def get : T
      @value
    end

    # Sets the value
    def set(value : T) : Nil
      @value = value
    end
  end

  # Cell is a mutable container for a value, allowing fields to update variables.
  # Similar to Go's pointer semantics but more Crystal-idiomatic.
  class Cell(T)
    property value : T

    def initialize(@value : T)
    end
  end

  # Backward-compatible alias for previous API name.
  Ref = Cell

  # PointerAccessor allows field value to be exposed as a pointed variable.
  class PointerAccessor(T)
    include Accessor(T)

    @cell : Cell(T)

    def initialize(@cell : Cell(T))
    end

    # Create a new pointer accessor from a value (creates a new cell)
    def self.new(value : T) : PointerAccessor(T)
      new(Cell(T).new(value))
    end

    # Gets the value
    def get : T
      @cell.value
    end

    # Sets the value
    def set(value : T) : Nil
      @cell.value = value
    end
  end

  # ProcAccessor uses procs to get and set values, useful for binding to external variables
  class ProcAccessor(T)
    include Accessor(T)

    @getter : Proc(T)
    @setter : Proc(T, Nil)

    def initialize(@getter : Proc(T), @setter : Proc(T, Nil))
    end

    # Gets the value
    def get : T
      @getter.call
    end

    # Sets the value
    def set(value : T) : Nil
      @setter.call(value)
    end
  end

  # Helper methods to create accessors
  def self.accessor_for(value : T) : Accessor(T) forall T
    EmbeddedAccessor(T).new(value)
  end

  # Create an accessor that binds to a cell (like Go's PointerAccessor)
  def self.pointer_accessor(cell : Cell(T)) : Accessor(T) forall T
    PointerAccessor(T).new(cell)
  end

  # Create an accessor that binds to procs
  def self.proc_accessor(getter : Proc(T), setter : Proc(T, Nil)) : Accessor(T) forall T
    ProcAccessor(T).new(getter, setter)
  end
end
