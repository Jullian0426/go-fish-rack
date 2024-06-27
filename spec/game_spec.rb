# frozen_string_literal: true

require 'rspec'
require_relative '../lib/game'
require_relative '../lib/player'

RSpec.describe Game do
  describe 'play_round' do
    let(:player1) { Player.new('Player 1') }
    let(:player2) { Player.new('Player 2') }
    let(:game) { Game.new([player1, player2]) }
    let(:card1) { Card.new('3', 'H') }
    let(:card2) { Card.new('6', 'H') }
    let(:card3) { Card.new('6', 'C') }
    let(:card4) { Card.new('10', 'C') }
    let(:card5) { Card.new('3', 'D') }
    let(:card6) { Card.new('3', 'C') }
    let(:card7) { Card.new('3', 'S') }

    before do
      game.start
      player1.hand = [card1, card2]
      player2.hand = [card3, card4]
    end

    it 'should take card from opponent and not change current player' do
      game.play_round(player2, '6')
      expect(player1.hand).to include(card3)
      expect(player2.hand).not_to include(card3)
      expect(game.current_player).to eq(player1)
    end

    it 'updates current player when fished card is not requested rank' do
      game.deck.cards = [card4]
      game.play_round(player2, '3')
      expect(player1.hand).to include(card4)
      expect(game.current_player).to eq(player2)
    end

    it 'does not update current player when fished card is requested rank' do
      game.deck.cards = [card5]
      game.play_round(player2, '3')
      expect(player1.hand).to include(card5)
      expect(game.current_player).to eq(player1)
    end

    it 'creates a book if possible' do
      player1.add_to_hand([card5, card6])
      game.deck.cards = [card7]
      game.play_round(player2, '3')
      expect(player1.hand).not_to include(card1, card5, card6, card7)
      expect(player1.books.first.cards).to include(card1, card5, card6, card7)
    end

    it 'does not create book if not possible' do
      player1.add_to_hand([card5])
      game.deck.cards = [card7]
      game.play_round(player2, '3')
      expect(player1.hand).to include(card1, card5, card7)
    end

    it 'returns the winner when a game is over' do
      player1.hand = [card1, card5, card6]
      player2.hand = [card7]
      game.deck.cards.clear
      game.play_round(player2, '3')
      expect(game.winner).to eq(player1)
    end
  end
end
