# oo_rps.rb
require 'pry'

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    self.score = 0
  end

  def to_s
    name.capitalize
  end

  def normalize(choice_selection)
    if Move::AVAILABLE_CHOICES.key(choice_selection).nil?
      choice_selection
    else
      Move::AVAILABLE_CHOICES.key(choice_selection)
    end
  end

  def choose_move
    self.choose!
  end

  def move_choice
    move.choice
  end
end

class Human < Player
  def set_name
    self.name = choose_name
  end

  def choose_name
    name = ''
    loop do
      print "Please enter your name\n: "
      name = gets.chomp
      break unless name.strip.empty?
      puts "You didn't type anything..."
    end

    name
  end

  def choose!
    selection = nil
    loop do
      print "\nPlease make a choice: #{Move.show_choice_options}\n: "
      selection = gets.chomp
      unless Move::AVAILABLE_CHOICES.to_a.flatten.include?(selection)
        puts "That's not a valid choice."
        next
      end
      break
    end

    self.move = Move.new(normalize(selection))
  end
end

class Computer < Player
  def set_name
    self.name = ['Doug', 'Philys', 'Dora', 'Bernard', 'Ned'].sample
  end

  def choose!
    selection = Move::AVAILABLE_CHOICES.keys.sample

    self.move = Move.new(selection)
  end
end

class Move
  AVAILABLE_CHOICES = { 'r' => 'rock', 'p' => 'paper', 'sc' => 'scissors', 'sp' => 'spock', 'l' => 'lizard' }
  attr_accessor :choice

  def initialize(choice)
    self.choice = choice if AVAILABLE_CHOICES.keys.include?(choice)
  end

  def self.show_choice_options
    AVAILABLE_CHOICES.collect do |choice|
      "#{choice.last.capitalize} (#{choice.first})"
    end.join(', ')
  end

  def to_s
    AVAILABLE_CHOICES[choice].capitalize
  end

  def paper?
    choice == 'p'
  end

  def rock?
    choice == 'r'
  end

  def scissors?
    choice == 'sc'
  end

  def spock?
    choice == 'sp'
  end

  def lizard?
    choice == 'l'
  end

  def >(other_move)
    (paper? && (other_move.rock? || other_move.spock?)) ||
      (rock? && (other_move.scissors? || other_move.lizard?)) ||
      (scissors? && (other_move.paper? || other_move.lizard?)) ||
      (lizard? && (other_move.paper? || other_move.spock?)) ||
      (spock? && (other_move.rock? || other_move.scissors?))
  end

  def <(other_move)
    !(self > other_move) && (choice != other_move.choice)
  end

  def win_action(other_move)
    if self > other_move
      "beats"
    else
      "is defeated by"
    end
  end
end

class RPS
  GAME_POINT = 9
  WINNING_SCORE = 10

  attr_accessor :computer, :player, :winner, :history

  def initialize
    display_welcome
    self.player = Human.new
    self.computer = Computer.new
    self.history = []
  end

  def display_welcome
    system 'clear'
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!"
  end

  def display_score
    puts "The score is #{player}: #{player.score}, #{computer}: #{computer.score}"
    puts "Game point!" if [player.score, computer.score].include?(GAME_POINT)
  end

  def assign_winner!
    self.winner = nil if player.move_choice == computer.move_choice
    self.winner = player if player.move > computer.move
    self.winner = computer if player.move < computer.move

    winner.score += 1 if winner
  end

  def display_winner
    if winner.nil?
      puts "\nYou both played #{player.move}. It's a tie!"
    else
      puts "\n#{player} played #{player.move}, #{computer} played #{computer.move}."
      puts "#{player.move} #{player.move.win_action(computer.move)} #{computer.move}!"
      puts "#{winner} wins!"
    end

    puts "\n#{winner} wins the game with #{winner.score} points!" if game_over?
  end

  def winning_hands
    self.history.collect { |match| match[:winner][:move] if match[:winner] }.compact
  end

  def sort_most_frequent(collection)
    collection.to_a.sort do |previous, element|
      element.last <=> previous.last
    end
  end

  def most_frequent_winning_hand
    winning_hand_summary = {}
    Move::AVAILABLE_CHOICES.keys.each { |move| winning_hand_summary[move] = 0 }

    winning_hands.each do |hand|
      winning_hand_summary[hand] += 1
    end

    sort_most_frequent(winning_hand_summary).each do |sorted_element|
      puts "#{Move::AVAILABLE_CHOICES[sorted_element.first].capitalize} won #{sorted_element.last} time(s)."
    end
  end

  def game_summary
    most_frequent_winning_hand
  end

  def previous_match
    self.history.keys.last
  end

  def record_match!
    if winner.nil?
      tie = computer
      loser = nil
    else
      loser = (winner == player ? computer : player)
      tie = nil
    end

    self.history << { tie: tie.move.choice } if tie
    self.history << { winner: { name: winner.name, move: winner.move.choice },
                      loser: { name: loser.name, move: loser.move.choice }
                    } if winner
  end

  def game_over?
    (player.score >= WINNING_SCORE || computer.score >= WINNING_SCORE)
  end

  def display_goodbye_message
    message = if winner == player
                "Good job #{player}!"
              else
                "Sorry for your loss :("
              end

    puts message if game_over?
    puts "\nGoodbye"
  end

  def play_again?
    answer = ''
    loop do
      print "\nPlay again? (y/n): "
      answer = gets.chomp.downcase
      puts ""
      break if %w(y n).include?(answer)
      print "What's that?"
    end
    answer.start_with?('y')
  end

  def reset_winner
    self.winner = nil
  end

  def play
    loop do
      display_score
      player.choose_move
      computer.choose_move
      assign_winner!
      display_winner
      record_match!
      break if game_over?
      reset_winner
      next if play_again?
      break
    end
    game_summary
    display_goodbye_message
  end
end

RPS.new.play
