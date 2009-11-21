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
      if need_health_to_finish_current? and safe_to_step_back?
        @warrior.walk! opposite_direction(nearest_enemy_direction)
        @queued_actions << :heal_to_full!
      else
        attack_close!
      end
    end

    def attack_close!

      if @warrior.feel.enemy?
        @warrior.attack!

      elsif @warrior.feel(:backward).enemy?

        if @took_strong_hit  # wizard
          @warrior.shoot! :backward
        else
          @warrior.pivot!
          @facing = opposite_absolute :facing
        end

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
        @warrior.walk! opposite_direction(nearest_enemy_direction)
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
      if (direction = feel_any_captives?)
        @warrior.rescue! direction
      elsif (direction = see_any_enemies?)
        attack_ranged! direction
      else
        explore_open!
      end
    end

    def attack_ranged!(direction)
      @warrior.walk! direction
    end

    def explore_open!
      if (stair_direction = see_stairs?)
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
    def move!(direction = relative_moving)
      @moving = absolute_moving direction
      @warrior.walk! direction
    end

    # Queued actions.  You should break out of them by checking the queue size
    # or some other condition guaranteed to change.  They should accept a queue
    # size, with a default of 0.  If no action is left in the queue, we'll drop
    # through to normal processing.

    # Assuming we're not in danger, heal until full.
    def heal_to_full!(queue_size = 0)
      unless in_danger? or not hurt?
        @warrior.rest!
        @queued_actions << :heal_to_full!
      end
    end

    def walk_toward_current_goal!(queue_size = 0)
      return if in_danger? or not @warrior.feel(relative_moving).empty?

      if badly_hurt?
        @warrior.rest!
      else
        move!
      end

      @queued_actions << :walk_toward_current_goal!
    end

  end
end
