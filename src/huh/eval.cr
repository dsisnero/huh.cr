# Eval is an evaluatable value, it stores a cached value and a function to
# recompute it. Its bindings are what we check to see if we need to recompute
# the value.
# NOTE: This is a simplified version without bindings hash for now.
module Huh
  class Eval(T)
    @val : T
    @fn : Proc(T)?

    # Creates a new Eval with an initial value
    def initialize(@val : T)
      @fn = nil
    end

    # Creates a new Eval with a function (no bindings support yet)
    def initialize(&block : -> T)
      @val = block.call
      @fn = block
    end

    # Value returns the current value
    def value : T
      @val
    end

    # Value= sets the value directly (clears function)
    def value=(val : T) : Nil
      @val = val
      @fn = nil
    end

    # Function sets the function for dynamic evaluation
    def function(fn : Proc(T)?) : Nil
      @fn = fn
    end

    # Update the value by calling the function if set
    def update : Bool
      if fn = @fn
        @val = fn.call
        true
      else
        false
      end
    end

    # Returns true if the value has a function (can be updated)
    def dynamic? : Bool
      !@fn.nil?
    end
  end
end
