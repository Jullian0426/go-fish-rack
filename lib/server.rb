# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'sinatra/respond_with'
require 'rack/contrib'
require_relative 'game'
require_relative 'player'

class Server < Sinatra::Base
  enable :sessions
  register Sinatra::RespondWith
  use Rack::JSONBodyParser
  def self.api_keys
    @@api_keys ||= []
  end

  def self.game
    @@game ||= Game.new
  end

  def validate_api_key
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    api_key = @auth.username
    self.class.game.players.find { |player| player.api_key == api_key }
  end

  def valid_name?
    params['name'] && params['name'].length >= 3
  end

  def self.reset!
    @@api_keys = nil
    @@game = nil
  end

  def start_game_if_possible
    return if self.class.game.started

    self.class.game.start if self.class.game.players.count >= Game::MIN_PLAYERS
  end

  get '/' do
    slim :index
  end

  post '/join' do
    redirect '/' unless valid_name?
    # TODO: move logic into models
    api_key = SecureRandom.hex(10)
    self.class.api_keys << api_key
    player = Player.new(params['name'], api_key)
    session[:session_player] = player
    self.class.game.add_player(player)
    start_game_if_possible
    respond_to do |f|
      f.html { redirect '/game' }
      f.json { json api_key: api_key }
    end
  end

  get '/game' do
    respond_to do |f|
      f.html do
        redirect '/' if self.class.game.players.empty? || session[:session_player].nil?
        slim :game, locals: { game: self.class.game, session_player: session[:session_player] }
      end
      f.json do
        halt 401, 'Unauthorized' unless validate_api_key
        json self.class.game.as_json
      end
    end
  end

  patch '/game' do
    opponent = params['opponent']
    rank = params['rank']
    self.class.game.play_round(opponent, rank)
    redirect '/game'
  end
end
