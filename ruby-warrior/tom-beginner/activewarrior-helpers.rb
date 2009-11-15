module ActiveWarrior
  module Helpers

    def set_up_warrior
      @warrior = warrior

      @max_health ||= @health
      @last_health ||= 0

      mark_seen
    end

    def mark_seen

    end

    def track_health
      @health = @warrior.health
      @took_damage = @health >= @last_health ? false : @last_health - @health
    end

    def starting_direction
      if see_stairs? :forward or see_captives? :backward
        :backward
      else 
        :forward
      end
    end

    # Visibility checks

    def safe_to_shoot?(direction = :forward)
      @warrior.look(direction).each do |space|
        return false if space.captive?
        return true if space.enemy?
      end
      false
    end

    def nothing_but_wall?
      @warrior.look.each do |space|
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

  end
end
