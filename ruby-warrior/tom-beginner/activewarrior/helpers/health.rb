module ActiveWarrior
  module Helpers
    module Health

      def hurt?
        @health <= @max_health - (@max_health / 10)
      end

      def badly_hurt?
        @health < (@max_health / 2)
      end

      def need_health_to_finish_current?
        false ### TODO
      end

      def took_strong_hit?
        (@took_damage || 0) > @health / 4
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
