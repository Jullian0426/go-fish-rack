# frozen_string_literal: true

class Player
  attr_accessor :api_key, :hand, :books
  attr_reader :name

  def initialize(name)
    @name = name
    @api_key = SecureRandom.hex(10)
    @hand = []
    @books = []
  end

  def add_to_hand(card)
    hand << card
  end

  def hand_has_rank?(rank)
    hand.any? { |card| card.rank == rank }
  end

  def as_json
    {
      name: name,
      api_key: api_key,
      hand: hand.map(&:as_json),
      books: books.map(&:as_json)
    }
  end
end
