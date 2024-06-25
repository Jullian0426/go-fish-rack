# frozen_string_literal: true

# Represents a book of playing cards
class Book
  attr_reader :cards

  def initialize(cards)
    @cards = cards
  end

  def rank
    cards.first.rank
  end

  def serialize
    {
      cards: cards.map(&:serialize)
    }
  end
end
