module ActiveWarrior
  module Actions

    def defend!

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

  end
end
