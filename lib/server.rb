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
  # TODO: store valid api keys as instance variable
  def api_keys
    @api_keys ||= []
  end

  def game
    @@game ||= Game.new
  end

  def validate_api_key
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    api_key = @auth.credentials.first
    game.players.each do |player|
      return player if player.api_key == api_key
    end
    nil
  end

  # TODO: reset! method

  get '/' do
    slim :index
  end

  post '/join' do
    api_key = SecureRandom.hex(10)
    api_keys << api_key
    player = Player.new(params['name'], api_key)
    session[:current_player] = player
    game.add_player(player)
    respond_to do |f|
      f.html { redirect '/game' }
      f.json { json api_key: api_key }
    end
  end

  get '/game' do
    respond_to do |f|
      f.html do
        redirect '/' if game.players.empty?
        slim :game, locals: { game: game, current_player: session[:current_player] }
      end
      f.json do
        halt 401, 'Unauthorized' unless validate_api_key
        json players: game.players
      end
    end
  end
end
