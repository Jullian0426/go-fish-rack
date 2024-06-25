# frozen_string_literal: true

class Game
  attr_accessor :players, :deck

  def initialize(players = [])
    @players = players
    @deck = []
  end

  def add_player(player)
    players << player
  end

  def serialize
    {
      players: players.map(&:serialize),
      deck: deck
    }
  end
end
