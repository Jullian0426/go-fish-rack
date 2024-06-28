# frozen_string_literal: true

require 'httparty'
require 'base64'

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
        'CONTENT_TYPE' => 'application/json',
        'HTTP_ACCEPT' => 'application/json'
      }
    })
    @api_key = response['api_key']
  end

  def get_game
    self.class.get('/game', {
      body: nil,
      headers: {
        # TODO: httparty basic auth
        'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64("#{api_key}:X")}",
        'HTTP_ACCEPT' => 'application/json'
      }
    })
  end

  def state_changed?
    get_game != game_state
  end

  def current_turn?
  end

  def turn_prompt
  end

  def send_turn(response)
  end
end
