require 'activewarrior-helpers'
require 'activewarrior-actions'

class Player
  include ActiveWarrior::Helpers
  include ActiveWarrior::Actions

  def play_turn(warrior)

    # Determine if it's the first turn so we can perform setup
    @first_turn = !defined? @warrior

    # The warrior is my only grasp on reality, hold onto it
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

end
