# Notes: Too cautious about healing; only need full health to survive a
#        wizard's hit.  Don't walk backward to heal unless you can't kill
#        the current enemy with current health.  However, if not in danger,
#        badly hurt, AND see enemies, then heal to full.
#        Would be nice to track which types of enemies you see.

require 'activewarrior/helpers'
require 'activewarrior/actions'

class Player
  include ActiveWarrior::Helpers
  include ActiveWarrior::Actions

  def play_turn(warrior)

    if not defined? @warrior
      @first_turn = true
      set_up_warrior(warrior)
    elsif @keep_first_turn
      @first_turn = true
      @keep_first_turn = false
    else
      @first_turn = false
    end

    # The warrior object passed in represents the current turn
    @warrior = warrior

    track_health

    # We can queue actions as a form of memory.  We tell them the size of the
    # queue so they can plan.  If it's zero, it was not a queued action.
    unless @queued_actions.empty?
      queue_size = @queued_actions.size
      send(@queued_actions.shift, queue_size)

      # If there are still queued actions, skip to next turn
      clean_up and return unless @queued_actions.empty?
    end

    if in_danger? or (@first_turn and safe_to_shoot?)
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
