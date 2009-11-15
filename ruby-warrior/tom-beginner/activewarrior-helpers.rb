module ActiveWarrior
  module Helpers

    def set_up_warrior
      @warrior = warrior

      @max_health ||= @health
      @last_health ||= 0

      @facing = :east
      @moving = :east

      @seen = []
      mark_seen
    end

    # Directional helpers

    def absolute_facing(direction)
      direction == :forward ? @facing : opposite_absolute(@facing)
    end

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

    # Visibility checks

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

    def visible?(directions = [:forward, :backward])
      directions.each do |direction|
        @warrior.look(direction).each do |space|  ### can this just be any?
          return true if yield space
        end
      end
      false
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

    # Health / damage checks

    def hurt?
      @health <= @max_health - (@max_health / 10)
    end

    def badly_hurt?
      @health < (@max_health / 2)
    end

    ### use this
    def strong_hit_threshhold
      @health / 4
    end

    def track_health
      @health = @warrior.health
      @took_damage = @health >= @last_health ? false : @last_health - @health
    end

  end
end
