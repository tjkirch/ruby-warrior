module ActiveWarrior
  module Helpers
    module Directional

      def absolute_facing(direction)
        direction == :forward ? @facing : opposite_absolute(@facing)
      end

      def absolute_moving(direction)
        direction == :forward ? @moving : opposite_absolute(@moving)
      end

      def opposite_absolute(absolute)
        ([:east, :west] - [absolute]).first
      end

      def opposite_direction(direction)
        ([:forward, :backward] - [direction]).first
      end

    end
  end
end
