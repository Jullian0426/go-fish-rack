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

  def as_json
    {
      name: name,
      api_key: api_key,
      hand: hand.map(&:as_json),
      books: books.map(&:as_json)
    }
  end
end
