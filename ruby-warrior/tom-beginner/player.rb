###require 'ruby-debug'; Debugger.start ###

class Player
  def play_turn(warrior)

    # It's my only grasp on reality
    @warrior = warrior

    # Keep track of current/max health so we know if we're hurt
    @health = warrior.health
    @max_health ||= @health
    @last_health ||= 0
    @took_damage = @health >= @last_health ? false : @last_health - @health

    if warrior.feel.wall?
      warrior.pivot!
    elsif warrior.feel.empty?
      act_on_empty_square!
    else
      act_on_occupied_square!
    end

    @last_health = warrior.health
  end

  private

  def act_on_occupied_square!
    if @warrior.feel.captive?
      @warrior.rescue!
    else
      @warrior.attack!
    end
  end

  def act_on_empty_square!
    if @took_damage
      danger_action_for_empty!
    else
      safe_action_for_empty!
    end
  end

  # Being attacked - panic!!
  def danger_action_for_empty!
    if badly_hurt?
      @warrior.walk! :backward
    else
      @warrior.walk!
    end
  end

  # Take our time if we're not being attacked
  def safe_action_for_empty!
    if safe_to_shoot?
      @warrior.shoot!
    elsif hurt? and (badly_hurt? or enemies_remaining?)
      @warrior.rest!
    else
      @warrior.walk!
    end
  end

  def safe_to_shoot?(direction = :forward)
    @warrior.look(direction).each do |space|
      return false if space.captive?
      return true if space.enemy?
    end
    false
  end

  def enemies_remaining?
    [:forward, :backward].each do |direction|
      @warrior.look(direction).each do |space|
        return true if space.enemy?
      end
    end
    false
  end

  def hurt?
    @health < @max_health
  end

  def badly_hurt?
    @health < (@max_health / 3)
  end
end
