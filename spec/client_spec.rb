# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/client'
require_relative '../lib/game'
require_relative '../lib/player'

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
      updated_game.start
      stub_request(:get, %r{/game})
        .to_return_json({ body: { game: test_game.as_json.to_json } },
                        { body: { game: updated_game.as_json.to_json } })

      client = Client.new(player_name: 'Test')
      client.game_state
      expect(client.state_changed?).to eq true
    end
  end

  describe '#current_turn?' do
    before do
      @test_game = Game.new
      stub_request(:get, %r{/game})
        .to_return_json(body: { game: @test_game.as_json.to_json })

      @client = Client.new(player_name: 'Test')
    end

    it "returns true if it is user's turn" do
      @client.game_state['is_turn'] = true
      expect(@client.current_turn?).to eq true
    end

    it "returns false if it is not user's turn" do
      @client.game_state['is_turn'] = false
      expect(@client.current_turn?).to eq false
    end
  end

  describe '#turn_prompt' do
    let(:player1) { Player.new('Player 1') }
    let(:player2) { Player.new('Player 2') }
    let(:game) { Game.new([player1, player2]) }

    before do
      @opponents_and_hand_regex = /
      Opponents:\s+Player\s+\d+(,\s+Player\s+\d+)*\n
      Your\shand:\s+[\dJQKA]{1,2}[HDCS](,\s*[\dJQKA]{1,2}[HDCS])*
      /
      @prompt_message = "Choose an opponent and a rank from your hand to ask for
      (ex: 1, 3 to ask the first player listed for 3's):"
    end

    it 'should prompt the client' do
      game.start
      stub_request(:get, %r{/game})
        .to_return_json(body: game.as_json(player1.api_key).to_json)

      client = Client.new(player_name: 'Test')
      client.game_state
      # TODO: get this to work
      # expect { client.turn_prompt }.to output(match(@opponents_and_hand_regex)).to_stdout
      expect { client.turn_prompt }.to output(include(@prompt_message)).to_stdout
    end
  end

  describe '#send_turn' do
    it 'sends opponent and rank choices' do
      test_game = Game.new
      stub_request(:post, %r{/game})
        .with(body: { "opponent" => "2", "rank" => "A" })
        .to_return_json(body: { game: test_game.as_json.to_json })

      client = Client.new(player_name: 'Test')
      response = client.send_turn('2, A')
      expect(response['game']).to eq test_game.as_json.to_json
    end
  end
end
