# Selector provides a helper type for selecting items.
module Huh
  class Selector(T)
    @items : Array(T)
    @index : Int32

    # Creates a new item selector
    def initialize(items : Array(T) = [] of T)
      @items = items
      @index = 0
    end

    # Creates a new item selector with varargs
    def self.new(*items : T) : Selector(T) forall T
      new(items.to_a)
    end

    # Append adds an item to the selector
    def append(item : T) : Nil
      @items << item
    end

    # Next moves the selector to the next item
    def next : Nil
      if @index < @items.size - 1
        @index += 1
      end
    end

    # Prev moves the selector to the previous item
    def prev : Nil
      if @index > 0
        @index -= 1
      end
    end

    # OnFirst returns true if the selector is on the first item
    def on_first? : Bool
      @index == 0
    end

    # OnLast returns true if the selector is on the last item
    def on_last? : Bool
      @index == @items.size - 1
    end

    # Selected returns the current selected item
    def selected : T
      @items[@index]
    end

    # Index returns the index of the current selected item
    def index : Int32
      @index
    end

    # Total returns the total number of items
    def total : Int32
      @items.size
    end

    # SetIndex sets the selected item
    def set_index(i : Int32) : Nil
      if i >= 0 && i < @items.size
        @index = i
      end
    end

    # Get returns the item at the given index
    def get(i : Int32) : T
      @items[i]
    end

    # Set sets the item at the given index
    def set(i : Int32, item : T) : Nil
      @items[i] = item
    end

    # Range iterates over the items
    # The callback function should return true to continue the iteration
    def range(&block : Int32, T -> Bool) : Nil
      @items.each_with_index do |item, i|
        unless block.call(i, item)
          break
        end
      end
    end

    # ReverseRange iterates over the items in reverse
    # The callback function should return true to continue the iteration
    def reverse_range(&block : Int32, T -> Bool) : Nil
      i = @items.size - 1
      while i >= 0
        unless block.call(i, @items[i])
          break
        end
        i -= 1
      end
    end

    # Items returns the underlying array (read-only)
    def items : Array(T)
      @items.dup
    end

    # Empty? returns true if there are no items
    def empty? : Bool
      @items.empty?
    end

    # Size returns the number of items (alias for total)
    def size : Int32
      total
    end
  end
end
