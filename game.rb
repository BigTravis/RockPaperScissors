require 'net/http'
require 'json'

# Game of rock, paper, scissors. Allows for custom options and rules to be used instead.
class Game
  attr_reader :options

  # Rules are defined as follows:
  # Nested hashes where player's choice is the key, and the value is a hash
  # that contains the computer's choice as the key and the winner as the value.
  # -1 = Player wins, 1 = Computer Wins, 0 = Tie.
  def initialize(options = ['rock', 'paper', 'scissors'],
                 rules = {'rock' => {'rock' => 0, 'scissors' => -1, 'paper' => 1},
                          'paper' => {'rock' => -1, 'scissors' => 1, 'paper' => 0},
                          'scissors' => {'rock' => 1, 'scissors' => 0, 'paper' => -1}})

    @options = options
    @rules = rules
  end

  # Method that calls the rock paper scissors API and determines the winner based on game rules
  # and player_choice. Returns a string of the outcome of the game from the player's perspective.
  def play(player_choice)
    computer_choice = nil
    player_choice = player_choice.downcase
    uri = URI('https://5eddt4q9dk.execute-api.us-east-1.amazonaws.com/rps-stage/throw')
    response = Net::HTTP.get_response(uri)

    if response.code == '200'
      computer_choice = JSON.parse(response.body)['body']
      unless computer_choice.nil?
        computer_choice = computer_choice[1, computer_choice.size - 2] # stripping extra quotes
      end

    end

    if computer_choice.nil? || @rules[computer_choice].nil?
      computer_choice = @rules.keys.sample
    end
    if player_choice.nil? || @rules[player_choice].nil?
      player_choice = @rules.keys.sample
    end

    case @rules[player_choice][computer_choice]
    when -1
      'You win!!'
    when 0
      "It's a tie!"
    when 1
      'You lose!'
    end
  end
end

if __FILE__ == $0
  game = Game.new
  puts 'Game of ', game.options
  puts 'Enter your choice: '
  choice = gets
  puts game.play choice
end

