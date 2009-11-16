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

        @facing = @moving = :east

        @queued_actions = []

        @seen = []
        mark_seen

        # Define methods on warrior instance to handle directional tracking
        class << @warrior
          def pivot!
            super
            @facing = opposite_absolute(@facing)
          end

          def walk!(direction)
            super(direction)
            @moving = absolute_moving(@moving)
          end

        end  # class << warrior
      end  # unless @warrior
    end  # def set_up_warrior

    def clean_up
      mark_seen
      @last_health = @warrior.health
    end

  end
end
