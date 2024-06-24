# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'sinatra/respond_with'
require 'rack/contrib'
require_relative 'game'
require_relative 'player'

class Server < Sinatra::Base
  def game
    @@game ||= Game.new
  end

  get '/' do
    slim :index
  end

  post '/join' do
    player = Player.new(params['name'])
    game.players << player
    redirect '/game'
  end

  get '/game' do
    redirect '/' if game.players.empty?
    slim :game, locals: { players: game.players }
  end
end
