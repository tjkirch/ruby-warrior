module ActiveWarrior
  module Helpers
    module Directional

      def absolute_facing(direction)
        direction == :forward ? @facing : opposite_absolute(@facing)
      end

      ### need?
      def absolute_moving(direction)
        direction == :forward ? @moving : opposite_absolute(@moving)
      end

      def opposite_absolute(absolute)
        ([:east, :west] - [absolute]).first
      end

      ### FIXME
      def starting_direction
        if see_stairs? :forward or see_captives? :backward
          :backward
        else 
          :forward
        end
      end

    end
  end
end
