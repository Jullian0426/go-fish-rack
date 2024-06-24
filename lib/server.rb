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

  def game
    @@game ||= Game.new
  end

  get '/' do
    slim :index
  end

  post '/join' do
    api_key = SecureRandom.hex(10)
    player = Player.new(params['name'], api_key)
    session[:current_player] = player
    game.add_player(player)
    respond_to do |f|
      f.html { redirect '/game' }
      f.json { json api_key: api_key }
    end
  end

  get '/game' do
    redirect '/' if game.players.empty?
    respond_to do |f|
      f.html { slim :game, locals: { game: game, current_player: session[:current_player] } }
      f.json { json players: game.players }
    end
  end
end
