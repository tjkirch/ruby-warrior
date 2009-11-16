require 'activewarrior/helpers/directional'
require 'activewarrior/helpers/senses'
require 'activewarrior/helpers/health'

module ActiveWarrior
  module Helpers
    include ActiveWarrior::Helpers::Directional
    include ActiveWarrior::Helpers::Senses
    include ActiveWarrior::Helpers::Health

    def set_up_warrior(warrior)
      unless @warrior
        @warrior = warrior

        @max_health ||= @warrior.health
        @last_health ||= 0

        @facing = @moving = @attacking = :east

        @queued_actions = []

        @seen = []
        mark_seen
      end
    end

    def clean_up
      mark_seen
      @last_health = @warrior.health
    end

  end
end
