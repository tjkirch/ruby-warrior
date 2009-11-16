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
        if nothing_but_wall?(direction) or (see_stairs? direction and
                                            not seen_everything?)
          move! opposite_direction(direction)
          return
        end
      end

      # If neither direction has a wall or stairs, just walk
      move!
    end

    def explore!
      if direction = feel_any_captives?
        @warrior.rescue! direction
      elsif direction = see_any_enemies?
        attack_ranged! direction
      else
        explore_open!
      end
    end

    def attack_ranged!(direction)
      if safe_to_shoot? direction
        @attacking = direction
        test_then_charge!
      else
        @warrior.walk! direction
      end
    end

    def explore_open!
      if stair_direction = see_stairs?
        walk_toward_unseen! stair_direction
      else 
        move!
      end
    end

    # Make sure we've seen the other side before going toward stairs
    def walk_toward_unseen!(stair_direction)
      if @seen.include? opposite_absolute(absolute_moving(stair_direction))
        move! stair_direction
      else
        move! opposite_direction(stair_direction)
      end
    end

    # For non-combat moving, change our recorded direction
    def move!(direction = @moving)
      @moving = direction
      @warrior.walk! direction
    end

    # Queued actions.  You should break out of them by checking the queue size
    # or some other condition guaranteed to change.

    # Assuming we're not in danger, heal until full.
    def heal_to_full!(queue_size)
      unless in_danger? or not hurt?
        @warrior.heal!
        @queued_actions << :heal_to_full!
      end
    end

    # Try to take out wizards ASAP; for others, attack head-on
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

    def test_then_charge!(queue_size)
      # On first call, shoot to test for wizards.
      if queue_size == 0
        @queued_actions << :test_then_charge!
        @warrior.shoot! @attacking

      # If an enemy is still there, charge.
      elsif see_any_enemies?  ### should check for same spot
        walk_toward_current_goal!
      end
    end

    def walk_toward_current_goal!
      unless in_danger? or not @warrior.feel(@moving).empty?
        @queued_actions << :walk_toward_current_goal!
        move!
      end
    end

  end
end
