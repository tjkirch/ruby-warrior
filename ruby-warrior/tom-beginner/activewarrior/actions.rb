module ActiveWarrior
  module Actions

    def defend!
      if feel_any_enemies?
        defend_melee!
      else
        defend_ranged!
      end
    end

    def defend_melee!
      if badly_hurt? and safe_to_step_back?
        @warrior.walk! opposite_absolute(nearest_enemy_direction)
        @queued_actions << :heal_to_full!
      else
        attack_close!
      end
    end

    def attack_close!
      if @warrior.feel.enemy?
        @warrior.attack!
      elsif @warrior.feel(:backward).enemy?
        test_back_then_pivot!
      end
    end

    def defend_ranged!
      if took_strong_hit?  # wizard
        @warrior.shoot! nearest_enemy_direction
      else
        defend_weak_ranged!
      end
    end

    def defend_weak_ranged!
      if badly_hurt? and not safe_to_charge?
        @warrior.walk! opposite_absolute(nearest_enemy_direction)
        @queued_actions << :heal_to_full!
      else
        @warrior.walk! nearest_enemy_direction
      end
    end

    def set_direction!
      [:backward, :forward].each do |direction|
        if nothing_but_wall?(direction) or (see_stairs? direction
                                            and not seen_everything?)
          @warrior.walk! opposite_direction(direction)
          return
        end
      end

      # If neither direction has a wall or stairs, just walk
      @warrior.walk!
    end

    def explore!
      if dir = feel_any_captives?
        @warrior.rescue! dir
      elsif see_any_enemies?
        ###
      else
        explore_open!
      end
    end

    def explore_open!
      ###
    end

    # Lock actions

    # Assuming we're not in danger, heal until full.
    def heal_to_full!(queue_size)
      unless in_danger?
        @warrior.heal!
        @queued_actions << :heal_to_full!
      end
    end

    def test_back_then_pivot!(queue_size = 0)
      # On first call, shoot back to test for wizards.
      if queue_size == 0
        @queued_actions << :test_back_then_pivot!
        @warrior.shoot! :backward

      # If the enemy is still there, turn to attack.
      elsif @warrior.feel(:backward).enemy?
        @warrior.pivot!
      end
    end

  end
end
