# frozen_string_literal: true

# Represents a playing card
class Card
  attr_reader :rank, :suit

  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUITS = %w[H D C S].freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def as_json
    {
      rank: rank,
      suit: suit
    }
  end
end
