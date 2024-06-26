# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
ENV['RACK_ENV'] = 'test'
require_relative '../lib/server'
require_relative '../lib/card'
require_relative '../lib/book'

RSpec.describe Server do
  include Capybara::DSL
  before do
    Capybara.app = Server.new
  end

  after do
    Server.reset!
  end

  it 'is possible to join a game' do
    visit '/'
    expect(page).not_to have_content('John')
    submit_player('John')
    expect(page).to have_content('John')
  end

  it 'redirects to root when player name is empty' do
    submit_player('')
    expect(page).to have_current_path('/')
  end

  it 'redirects to root when player name is less than 3' do
    submit_player('ag')
    expect(page).to have_current_path('/')
  end

  before do
    @session1 = Capybara::Session.new(:rack_test, Server.new)
    @session2 = Capybara::Session.new(:rack_test, Server.new)
    [@session1, @session2].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
    end
  end

  it 'allows multiple players to join game' do
    [@session1, @session2].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      expect(session).to have_content('Players')
      expect(session).to have_css('b', text: player_name)
    end
    expect(@session2).to have_content('Player 1')
    @session1.driver.refresh
    expect(@session1).to have_content('Player 2')
  end

  before do
    game = Server.game
    game.players.first.hand = [Card.new('3', 'H')]
    game.players.last.hand = [Card.new('6', 'C')]
    game.players.first.books = [Book.new([Card.new('7', 'D')])]
    game.players.last.books = [Book.new([Card.new('8', 'S')])]

    refresh_sessions
  end

  it 'should display session player hand and books' do
    expect(@session1).to have_content('3, H')
    expect(@session1).not_to have_content('6, C')
    expect(@session1).to have_content('7, D').and have_content('8, S')
    expect(@session2).to have_content('6, C')
    expect(@session2).not_to have_content('3, H')
    expect(@session2).to have_content('7, D').and have_content('8, S')
  end

  def submit_player(name)
    visit '/'
    fill_in :name, with: name
    click_on 'Join'
  end

  def refresh_sessions
    @session1.driver.refresh
    @session2.driver.refresh
  end
end

RSpec.describe Server do
  include Rack::Test::Methods
  def app
    Server.new
  end

  after do
    Server.reset!
  end

  it 'returns game status via API' do
    api_post
    api_key = JSON.parse(last_response.body)['api_key']
    expect(api_key).not_to be_nil
    api_get(api_key)
    expect(last_response.status).to eq 200
    expect(last_response).to match_json_schema('game')
  end

  it 'returns 401 error if api_key is not authorized' do
    api_key = SecureRandom.hex(10)
    api_get(api_key)
    expect(last_response.status).to eq(401)
  end

  def api_get(api_key)
    get '/game', nil, {
      'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64("#{api_key}:X")}",
      'HTTP_ACCEPT' => 'application/json'
    }
  end

  def api_post
    post '/join', { 'name' => 'Caleb' }.to_json, {
      'HTTP_ACCEPT' => 'application/json',
      'CONTENT_TYPE' => 'application/json'
    }
  end
  # TODO: take a turn
end
