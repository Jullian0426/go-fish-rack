# frozen_string_literal: true

class Player
  attr_accessor :api_key, :hand, :books
  attr_reader :name

  def initialize(name, api_key = '')
    @name = name
    @api_key = api_key
    @hand = []
    @books = []
  end

  def serialize
    {
      name: name,
      api_key: api_key,
      hand: hand.map(&:serialize),
      books: books.map(&:serialize)
    }
  end
end
