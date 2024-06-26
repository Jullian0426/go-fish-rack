# frozen_string_literal: true

require_relative 'deck'

class Game
  attr_accessor :players, :deck

  def initialize(players = [])
    @players = players
    @deck = Deck.new
  end

  def add_player(player)
    players << player
  end

  def as_json
    {
      players: players.map(&:as_json),
      deck: deck.as_json
    }
  end
end
