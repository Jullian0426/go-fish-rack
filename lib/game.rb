# frozen_string_literal: true

require_relative 'deck'

class Game
  attr_accessor :players, :deck, :started

  def initialize(players = [])
    @players = players
    @deck = Deck.new
    @started = false
  end

  def add_player(player)
    players << player
  end

  def start
    deck.shuffle

    STARTING_HAND_SIZE.times do
      players.each { |player| player.add_to_hand(deck.deal) }
    end
    self.started = true
  end

  def as_json
    {
      players: players.map(&:as_json),
      deck: deck.as_json
    }
  end

  MIN_PLAYERS = 2
  STARTING_HAND_SIZE = 5
end
