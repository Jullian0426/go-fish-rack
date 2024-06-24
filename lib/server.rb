# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'sinatra/respond_with'
require 'rack/contrib'

class Server < Sinatra::Base
  def self.game
    @@game ||= Game.new
  end
  get '/' do
    slim :index
  end
  post '/join' do
    player = Player.new(params['name'])
    session[:current_player] = player
    self.class.game.add_player(player)
    redirect '/game'
  end
  get '/game' do
    redirect '/' if self.class.game.empty?
    slim :game, locals: { game: self.class.game, current_player: session[:current_player] }
  end
end