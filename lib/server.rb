# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'sinatra/respond_with'
require 'rack/contrib'
require_relative 'game'

class Server < Sinatra::Base
  def game
    @@game ||= Game.new
  end

  get '/' do
    @players = game.players
    slim :index, locals: { game: game }
  end

  post '/join' do
    player = params['name']
    game.players << player
    redirect '/'
  end

  # get '/game' do
  #   redirect '/' if self.class.game.empty?
  #   slim :game, locals: { game: self.class.game, current_player: session[:current_player] }
  # end
end
