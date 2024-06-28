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
    WebMock.disable!
  end

  after do
    Server.reset!
    WebMock.enable!
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
      expect(session).to have_css('strong', text: player_name)
    end
    expect(@session2).to have_content('Player 1')
    @session1.driver.refresh
    expect(@session1).to have_content('Player 2')
  end

  before do
    @game = Server.game
    @game.players.first.hand = [Card.new('3', 'H'), Card.new('6', 'H')]
    @game.players.last.hand = [Card.new('6', 'C'), Card.new('10', 'C')]
    @game.players.first.books = [Book.new([Card.new('7', 'D')])]
    @game.players.last.books = [Book.new([Card.new('8', 'S')])]

    refresh_sessions
  end

  it 'should display session player hand and books' do
    expect(@session1).to have_content('3, H').and have_content('6, H')
    expect(@session1).not_to have_content('6, C')
    expect(@session1).to have_content('7, D').and have_content('8, S')
    expect(@session2).to have_content('6, C').and have_content('10, C')
    expect(@session2).not_to have_content('3, H')
    expect(@session2).to have_content('7, D').and have_content('8, S')
  end

  it "should display turn actions to game's current player" do
    expect(@session1).to have_content('Take Turn')
    expect(@session2).not_to have_content('Take Turn')
    Server.game.next_player
    refresh_sessions
    expect(@session1).not_to have_content('Take Turn')
    expect(@session2).to have_content('Take Turn')
  end

  describe 'Post /game' do
    it 'should update player hands to reflect taking a card' do
      @session1.select 'Player 2', from: 'player'
      @session1.select '6', from: 'rank'
      @session1.click_on 'Take Turn'
      refresh_sessions
      expect(@session1).to have_content('6, C')
      expect(@session2).not_to have_content('6, C')
    end

    it 'should not run play_round if user is not current player' do
      initial_game_state = @game.players.dup
      @session1.select 'Player 2', from: 'player'
      @session1.select '6', from: 'rank'
      @game.next_player
      @session1.click_on 'Take Turn'
      expect(@game.players).to eq(initial_game_state)
    end
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

  it 'returns 401 error if api_key is not authorized' do
    api_key = SecureRandom.hex(10)
    api_get_game(api_key)
    expect(last_response.status).to eq(401)
  end

  before do
    @player1_key = join_and_get_game('Player 1').first
    @player2_key, @player2_data = join_and_get_game('Player 2')
    api_get_game(@player1_key)
    @player1_data = json_body
  end

  it 'returns game status via API' do
    expect(last_response.status).to eq 200
    expect(last_response).to match_json_schema('game')
  end

  it 'returns appropriate amounts of player data' do
    player2_data_for_player1 = @player2_data['players'].first

    expect(player2_data_for_player1).not_to have_key('api_key')
    expect(player2_data_for_player1).not_to have_key('hand')
  end

  describe 'Post /game' do
    it 'returns the updated game' do
      player1_card = @player1_data['players'].first['hand'].first
      api_post_game(@player1_key, '2', player1_card['rank'].to_s)
      updated_player1_data = json_body
      expect(updated_player1_data).not_to eq(@player1_data)
    end

    it "returns 401 error if it's not this player's turn" do
      player1_card = @player1_data['players'].first['hand'].first
      api_post_game(@player2_key, '2', player1_card['rank'].to_s)
      expect(last_response.status).to eq(401)
    end
  end

  def join_and_get_game(name)
    api_post_join(name)
    api_key = json_body['api_key']
    api_get_game(api_key)
    game_data = json_body
    [api_key, game_data]
  end

  def json_body
    JSON.parse(last_response.body)
  end

  def api_get_game(api_key)
    get '/game', nil, {
      'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64("#{api_key}:X")}",
      'HTTP_ACCEPT' => 'application/json'
    }
  end

  def api_post_join(name)
    post '/join', { 'name' => name }.to_json, {
      'HTTP_ACCEPT' => 'application/json',
      'CONTENT_TYPE' => 'application/json'
    }
  end

  def api_post_game(api_key, player, rank)
    post '/game', { 'opponent' => player, 'rank' => rank }.to_json, {
      'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64("#{api_key}:X")}",
      'HTTP_ACCEPT' => 'application/json',
      'CONTENT_TYPE' => 'application/json'
    }
  end
end
