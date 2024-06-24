# frozen_string_literal: true

class Game
  attr_accessor :players

  def initialize(players = [])
    @players = players
  end
end
