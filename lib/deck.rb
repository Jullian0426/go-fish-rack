# frozen_string_literal: true

require_relative 'card'

# Represents a deck of cards
class Deck
  attr_accessor :cards

  def initialize(cards = make_cards)
    @cards = cards
  end

  def shuffle(seed = Random.new)
    cards.shuffle!(random: seed)
  end

  def make_cards
    Card::SUITS.flat_map do |suit|
      Card::RANKS.map do |rank|
        Card.new(rank, suit)
      end
    end
  end

  def deal
    cards.pop
  end

  def as_json
    {
      cards: cards.map(&:as_json)
    }
  end
end
