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

  it 'is possible to join a game' do
    visit '/'
    expect(page).not_to have_content('John')
    fill_in :name, with: 'John'
    click_on 'Join'
    expect(page).to have_content('John')
  end
end
