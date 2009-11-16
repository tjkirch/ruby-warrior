module ActiveWarrior
  module Helpers
    module Senses

      def mark_seen
        [:backward, :forward].each do |direction|
          if nothing_but_wall? direction
            @seen << absolute_facing(direction)
          end
        end
      end

      def safe_to_shoot?(direction = :forward)
        @warrior.look(direction).each do |space|
          return false if space.captive?
          return true if space.enemy?
        end
        false
      end

      def nothing_but_wall?(direction = :forward)
        @warrior.look(direction).each do |space|
          return false if space.stairs? or (!space.empty? and !space.wall?)
          return true if space.wall?
        end
        false
      end

      def touchable?(directions = [:forward, :backward])
        directions.each do |direction|
          @warrior.feel(direction).instance_eval do
            return true if yield self
          end
        end
        false
      end

      def feel_any_enemies?
        touchable? { |s| s.enemy? }
      end

      def visible?(directions = [:forward, :backward], &block)
        directions.any? do |direction|
          @warrior.look(direction).any? &block
        end
      end

      def see_any_enemies?
        visible? { |s| s.enemy? }
      end

      def see_captives? directions
        directions = [directions] unless directions.respond_to? :each

        visible?(directions) { |s| s.captive? }
      end

      def see_stairs? directions
        directions = [directions] unless directions.respond_to? :each

        visible?(directions) { |s| s.stairs? }
      end

      def seen_everything?
        [:east, :west].all? { |dir| @seen.include? dir }
      end

      # Safe to step back from melee combatant?
      def safe_to_step_back?
        spaces_behind = @warrior.look(:backward)[0..1]

        return spaces_behind.all? { |s| s.empty? } ||
              (spaces_behind[0].empty? && !spaces_behind[1].enemy?)
      end

      # Safe to retreat from ranged combatant?  It takes two turns to kill an
      # archer in melee, plus one to move in.
      def safe_to_charge?
        d = nearest_enemy_distance
        d <= 2 and @health > (@took_damage * (d + 1))
      end

      def in_danger?
        feel_any_enemies? or @took_damage
      end

      def nearest_for(&block)
        [:forward, :backward].each do |direction|
          @warrior.look(direction).each_with_index do |s, i|
            if block.call s
              nearest[:direction] = i
              break
            end
          end
        end

        return nil if not nearest
        nearest.sort_by { |k, v| v }.first
      end

      def nearest_direction_for(&block)
        nearest_for(&block)[0]
      end

      def nearest_distance_for(&block)
        nearest_for(&block)[1]
      end

      def nearest_enemy_direction
        nearest_direction_for { |s| s.enemy? }
      end

      def nearest_enemy_distance
        nearest_distance_for { |s| s.enemy? }
      end

    end
  end
end
