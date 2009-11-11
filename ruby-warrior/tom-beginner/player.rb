###require 'ruby-debug'; Debugger.start ###

# Notes: If you're not actively being attacked, don't just shoot!, charge them

class Player
  def play_turn(warrior)

    # Perform setup on first turn
    @first_turn = !defined? @warrior

    # It's my only grasp on reality
    @warrior = warrior

    track_health

    if @first_turn and starting_direction != :forward 
      warrior.pivot!
    elsif nothing_but_wall?
      warrior.pivot!
    elsif warrior.feel.empty?
      act_on_empty_square!
    else
      act_on_occupied_square!
    end

    @last_health = warrior.health
  end

  private

  def track_health
    @health = @warrior.health
    @max_health ||= @health
    @last_health ||= 0
    @took_damage = @health >= @last_health ? false : @last_health - @health
  end

  def starting_direction
    if see_stairs? :forward or see_captives? :backward
      :backward
    else 
      :forward
    end
  end

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
    elsif hurt? and (badly_hurt? or see_any_enemies?)
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

  def hurt?
    @health < @max_health
  end

  def badly_hurt?
    @health < (@max_health / 3)
  end
end
