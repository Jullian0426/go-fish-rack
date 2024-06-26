# frozen_string_literal: true

require_relative 'deck'

class Game
  attr_accessor :players, :deck, :started, :current_player

  def initialize(players = [])
    @players = players
    @deck = Deck.new
    @started = false
    @current_player = nil
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
    self.current_player = players.first
  end

  def next_player
    self.current_player = players[(players.index(current_player) + 1) % players.size]
  end

  def as_json
    {
      players: players.map(&:as_json),
      deck: deck.as_json,
      started: started,
      current_player: current_player.as_json
    }
  end

  MIN_PLAYERS = 2
  STARTING_HAND_SIZE = 5
end
