# frozen_string_literal: true

require_relative 'deck'

class Game
  attr_accessor :players, :deck, :started, :current_player, :stay_turn, :winner

  def initialize(players = [])
    @players = players
    @deck = Deck.new
    @started = false
    @current_player = nil
    @stay_turn = false
    @winner = nil
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

  def play_round(opponent, rank)
    if opponent.hand_has_rank?(rank)
      take_cards(opponent, rank)
    else
      go_fish(rank)
    end
    finalize_turn
  end

  def take_cards(opponent, rank)
    cards_to_move = opponent.remove_by_rank(rank)
    current_player.add_to_hand(cards_to_move)
    self.stay_turn = true
  end

  def go_fish(rank)
    drawn_card = deck.deal
    current_player.add_to_hand([drawn_card])
    self.stay_turn = drawn_card.rank == rank
  end

  def finalize_turn
    create_book_if_possible(current_player)
    next_player unless stay_turn
    game_over
    # TODO: deal cards to players with empty hands
  end

  def create_book_if_possible(player)
    ranks = player.hand.map(&:rank)
    book_rank = ranks.find { |rank| ranks.count(rank) == 4 }
    return unless book_rank

    book_cards = player.remove_by_rank(book_rank)
    new_book = Book.new(book_cards)
    player.books << new_book
  end

  def next_player
    self.current_player = players[(players.index(current_player) + 1) % players.size]
  end

  def game_over
    return unless deck.cards.empty? && players.all? { |player| player.hand.empty? }

    self.winner = players.max_by { |player| player.books.size }
  end

  def can_play_round?(api_key)
    current_player.api_key == api_key
  end

  def as_json(api_key = '')
    {
      players: players.map do |player|
                 player.as_json(player.api_key == api_key)
               end,
      current_player: current_player&.as_json(current_player.api_key == api_key),
      deck: deck.as_json,
      started: started,
      stay_turn: stay_turn,
      winner: winner&.as_json
    }
  end

  MIN_PLAYERS = 2
  STARTING_HAND_SIZE = 5
end
