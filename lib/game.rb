# frozen_string_literal: true

class Game
  attr_accessor :players

  def initialize(players = [])
    @players = players
  end

  def add_player(player)
    players << player
  end
end
