require 'activewarrior-helpers'
require 'activewarrior-actions'

class Player
  include ActiveWarrior::Helpers
  include ActiveWarrior::Actions

  def play_turn(warrior)

    unless defined? @warrior
      @first_turn = true
      set_up_warrior 
    elsif @keep_first_turn
      @first_turn = true
      @keep_first_turn = false
    else
      @first_turn = false
    end

    track_health

    if in_danger?
      @keep_first_turn = true if @first_turn
      ###
    elsif @first_turn
      ###
    else
      ###
    end

=begin
    if @first_turn and starting_direction != :forward 
      warrior.pivot!
    elsif nothing_but_wall?
      warrior.pivot!
    elsif warrior.feel.empty?
      act_on_empty_square!
    else
      act_on_occupied_square!
    end
=end

    mark_seen
    @last_health = warrior.health
  end

end
