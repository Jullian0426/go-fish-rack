# frozen_string_literal: true

require 'httparty'
require 'base64'
require 'json'

class Client
  include HTTParty

  attr_reader :player_name, :api_key

  def initialize(player_name:, url: 'http://localhost:9292')
    self.class.base_uri url
    @player_name = player_name
  end

  def game_state
    @game_state ||= get_game
  end

  def join_game
    response = self.class.post('/join', {
      body: { name: player_name }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    })
    @api_key = response['api_key']
  end

  def get_game
    response = self.class.get('/game', {
      body: nil,
      headers: {
        # TODO: httparty basic auth
        'AUTHORIZATION' => "Basic #{Base64.encode64("#{api_key}:X")}",
        'Accept' => 'application/json'
      }
    })
    JSON.parse(response.body)
  end

  def state_changed?
    new_game_state = get_game
    return false unless new_game_state != @game_state

    @game_state = new_game_state
    true
  end

  def current_turn?
    game_state['is_turn']
  end

  def turn_prompt
    opponents_string, hand_string = hand_and_opponents
    message = "#{opponents_string}
      #{hand_string}
      Choose an opponent and a rank from your hand to ask for
      (ex: 1, 3 to ask the first player listed for 3's):"
    puts(message)
  end

  def send_turn(response)
    opponent, rank = response.split(',').map(&:strip)
    self.class.post('/game', {
      body: { opponent: opponent, rank: rank }.to_json,
      headers: {
        'AUTHORIZATION' => "Basic #{Base64.encode64("#{api_key}:X")}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    })
  end

  def hand_and_opponents
    opponents = game_state['players'].reject { |player| player == game_state['current_player'] }
    opponents_string = "Opponents: #{opponents.map { |player| player['name'] }.join(', ')}".strip
    hand = game_state['current_player']['hand'].map { |card| "#{card['rank']}#{card['suit']}" }.join(', ')
    hand_string = "Your hand: #{hand}".strip
    [opponents_string, hand_string]
  end
end
