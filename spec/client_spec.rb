# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/client'
require_relative '../lib/game'

RSpec.describe Client do
  describe '#join_game' do
    it 'connects to server and stores API key' do
      test_api_key = 'random_string'
      stub_request(:post, %r{/join})
        .to_return_json(body: { api_key: test_api_key })

      client = Client.new(player_name: 'Test')
      client.join_game
      expect(client.api_key).to eq test_api_key
    end
  end

  describe '#game_state' do
    it 'should retreive the current game state' do
      test_game = Game.new
      stub_request(:get, %r{/game})
        .to_return_json(body: { game: test_game.as_json.to_json })

      client = Client.new(player_name: 'Test')
      response = client.game_state
      expect(response['game']).to eq test_game.as_json.to_json
    end
  end

  describe '#state_changed?' do
    it 'returns true if game state has changed' do
      test_game = Game.new
      updated_game = Game.new
      stub_request(:get, %r{/game})
        .to_return_json({ body: { game: test_game.as_json.to_json } },
                        { body: { game: updated_game.as_json.to_json } })

      client = Client.new(player_name: 'Test')
      client.game_state
      expect(client.state_changed?).to eq true
    end
  end
end
