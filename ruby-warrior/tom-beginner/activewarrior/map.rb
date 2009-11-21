module ActiveWarrior

  # A 2d map of the current dungeon.  Index 0 is always the warrior because the
  # map is updated after any move.  (Map should not be updated unless warrior
  # moved.)  Negative indices represent west, positive represent east.
  class Map
    include Enumerable

    CENTER = 100
    VISIBILITY_RANGE = 3

    def initialize
      @layout = []
      @min_x = @max_x = @location = CENTER
    end

    # Update a section of the map centered around current_location.
    # Maps are currently 2d, so current_location is an x value.
    def update(current_location, visible)
      @location = current_location

      offset = visible.size / 2
      min = absolute_location - offset
      max = absolute_location + offset

      @layout[min..max] = visible

      @min_x = min < @min_x ? min : @min_x
      @max_x = max > @max_x ? max : @max_x
    end

    def currently_visible
      min = absolute_location - VISIBILITY_RANGE
      max = absolute_location + VISIBILITY_RANGE

      min = min < @min_x ? @min_x : min
      max = max > @max_x ? @max_x : max

      @layout[min..max]
    end

    def [](offset); @layout[absolute_location + offset]; end

    def layout; @layout[@min_x..@max_x]; end

    def each(&b); layout.each(&b); end

    private

    def absolute_location; CENTER + @location; end

  end
end
