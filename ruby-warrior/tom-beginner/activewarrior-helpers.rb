module ActiveWarrior
  module Helpers

    def set_up_warrior(warrior)
      unless @warrior
        @warrior = warrior

        @max_health ||= @warrior.health
        @last_health ||= 0

        @facing = @moving = :east

        @queued_actions = []

        @seen = []
        mark_seen

        def @warrior.pivot!
          super
          @facing = opposite_absolute(@facing)
        end

        def @warrior.walk!(direction)
          ### TODO
          super(direction)
        end
      end
    end

    def clean_up
      mark_seen
      @last_health = @warrior.health
    end

    # Directional helpers

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

    # Sense helpers

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

      return spaces_behind.all? { |s| s.empty? } or
             spaces_behind[0].empty? and not spaces_behind[1].enemy?
    end

    # Safe to retreat from ranged combatant?
    def safe_to_retreat?
      ###
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

    # Health / damage checks

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
