module ActiveWarrior
  module Helpers
    module Health

      def hurt?
        @health <= @max_health - (@max_health / 10)
      end

      def badly_hurt?
        @health < (@max_health / 2)
      end

      def took_strong_hit?
        @took_damage > @health / 4
      end

      def track_health
        @health = @warrior.health

        if @health >= @last_health
          @took_damage = false 
        else
          @took_damage = @last_health - @health
        end
      end

    end
  end
end
