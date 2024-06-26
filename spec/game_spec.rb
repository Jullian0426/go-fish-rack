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

    before do
      player1.hand = [card1, card2]
      player2.hand = [card3, card4]
    end
    it 'should take card from opponent and give it to current player' do
      game.play_round(player2, '6')
      expect(player1.hand).to include(card3)
      expect(player2.hand).not_to include(card3)
    end
  end
end
