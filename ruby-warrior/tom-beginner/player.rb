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

    # We can "lock in" to certain actions, like healing,
    # to perform them repeatedly
    if @lock_action
      send @lock_action

      # If the lock is still set, skip other actions
      clean_up and return if @lock_action
    end

    if in_danger?
      @keep_first_turn = true if @first_turn
      defend!
    elsif @first_turn
      set_direction!
    else
      explore!
    end

    clean_up
  end

end
