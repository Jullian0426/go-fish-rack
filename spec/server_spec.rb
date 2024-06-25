# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
ENV['RACK_ENV'] = 'test'
require_relative '../lib/server'
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

  # TODO: Display session player hand/books and opponent books
  it 'should display hand only for session player' do
    
  end

  def submit_player(name)
    visit '/'
    fill_in :name, with: name
    click_on 'Join'
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
    expect(JSON.parse(last_response.body).keys).to include 'players'
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
