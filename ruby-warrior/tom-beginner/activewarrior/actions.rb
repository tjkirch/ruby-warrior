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
      ### TODO
    end

    def explore!
      ### TODO
    end

    ### needed?
    def act_on_occupied_square!
      if @warrior.feel.captive?
        @warrior.rescue!
      else
        @warrior.attack!
      end
    end

    ### needed?
    def act_on_empty_square!
      if @took_damage
        danger_action_for_empty!
      else
        safe_action_for_empty!
      end
    end

    ### needed?
    def danger_action_for_empty!
      if badly_hurt?
        @warrior.walk! :backward
      else
        @warrior.walk!
      end
    end

    ### needed?
    def safe_action_for_empty!
      if safe_to_shoot?
        @warrior.shoot!
      elsif hurt? and (badly_hurt? or see_any_enemies?)
        @warrior.rest!
      else
        @warrior.walk!
      end
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
