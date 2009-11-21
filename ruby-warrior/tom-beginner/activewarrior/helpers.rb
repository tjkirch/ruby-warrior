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

        @map ||= ActiveWarrior::Map.new
        update_map

        @max_health ||= @warrior.health
        @last_health ||= 0

        @facing = @moving = @attacking = :east

        @queued_actions = []

        @seen = []
        mark_seen
      end
    end

    def update_map
      if @warrior.respond_to? :look!
        visible = @warrior.look!(:backward) + @warrior.look(:forward)
      else # don't have look capability yet
        visible = [@warrior.feel!(:backward), @warrior.feel(:forward)]
      end

      # Send the visible spaces to our Map west-to-east
      visible.reverse! if absolute_facing == :west

      @map.update(@current_location, visible)  ### set current_location on move
    end

    def clean_up
      mark_seen
      update_map
      @last_health = @warrior.health
    end

  end
end
