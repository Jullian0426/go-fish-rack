# frozen_string_literal: true

require_relative 'client'

arguments = {}
print 'Enter the server url: (Enter for default)'
url = gets.chomp
arguments[:url] = url unless url.empty?
print "What is your name?\n"
name = gets.chomp
arguments[:player_name] = name
client = Client.new(**arguments)
client.join_game
loop do
  puts client.game_state if client.state_changed?
  if client.current_turn?
    puts client.turn_prompt
    client.send_turn(gets.chomp)
  end
  sleep 0.1
end
