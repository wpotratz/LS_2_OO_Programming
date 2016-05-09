# ~/workspace/training/launchschool/5_larger_programs/oo_ttt.rb

=begin

  1) Game Description:
    Tic-tac-toe is played on a board/grid which stores and displays X, O or blank (' '). A human and the computer are the only two players who alternate turns putting their marker on a chosen blank space. The starting player is determined randomly to begin the game. A game is ended once a player wins or the grid is filled (leaving no empty spaces). A player wins by getting three of their markers in a row. The loser of each round always starts the next game.

  2) Extract nouns and verbs:
    Game
    Square
    Board (a collection of squares with specific locations)
    - display
    Player
    - mark
    - play

=end

# To do:
# - move appropriate methdos to private
# - refactor large methods
# - move any appropriate methods from game to board class
# - refactor for messaging after choosing r to reset

require 'pry'

# Messaging allows formatted messaging rather than messages using puts

module Messaging
  def prompt(message)
    puts "=> #{message}"
  end

  def prompt_long(message)
    puts "\n=> #{message}\n\n"
  end

  def prompt_short(message)
    print "=> #{message}"
  end
end

# The board contains all of the squares, their locations, defines winning lines and displays the board

class Board
  include Messaging

  attr_reader :grid, :winning_lines, :board_width

  def initialize
    set_board_size!
    @grid = build_grid
    @winning_lines = set_winning_lines
    clear_markers!
  end

  def build_lines(starting_point, step, options = { walk_starting_point: false })
    lines = []
    if options[:walk_starting_point]
      case options[:walk_direction]
      when :vertical
        line_size.times do
          lines << [starting_point]
          starting_point += line_size
        end
      when :horizontal
        line_size.times do
          lines << [starting_point]
          starting_point += 1
        end
      end
    else
      lines << [starting_point]
    end

    (line_size - 1).times { lines.each { |square| square << square.last + step } }

    lines
  end

  def set_board_size!
    board_width_range = ((Player.all.count + 1)..10)

    prompt 'How wide would you like your board?'
    prompt "(Between #{board_width_range.first} and #{board_width_range.last} squares)."
    prompt_short ': '
    choice = 0
    loop do
      choice = gets.chomp.to_i
      break if board_width_range.include?(choice)
      prompt "Please make sure you chose a number between #{board_width_range.first} and #{board_width_range.last}."
      prompt_short ': '
    end

    @board_width = choice
  end

  def set_winning_lines
    winning_lines = []
    horizontal_step = 1
    vertical_step = line_size
    diagonal_slope_right_step = line_size + 1
    diagonal_slope_left_step = line_size - 1

    winning_lines += build_lines(1, vertical_step, { walk_starting_point: true, walk_direction: :horizontal })
    winning_lines += build_lines(1, horizontal_step, { walk_starting_point: true, walk_direction: :vertical })
    winning_lines += build_lines(1, diagonal_slope_right_step)
    winning_lines += build_lines(line_size, diagonal_slope_left_step)

    winning_lines
  end

  def build_grid
    grid_of_squares = {}

    (1..(board_width**2)).each { |space| grid_of_squares[space] = nil }

    grid_of_squares
  end

  def board_spaces
    (1..grid.keys.last).to_a
  end

  def line_size
    Math.sqrt(grid.size).to_i
  end

# rubocop:disable Metrics/AbcSize
  def display(options = { clear_screen: true })
    system 'clear' if options[:clear_screen]

    space_index = grid.keys.to_enum
    board_size_multiplier = line_size - 2
    v_piece_1 = '     |     '
    v_piece_2 = '|     '
    h_piece_1 = '-----+-----'
    h_piece_2 = '+-----'
    line_piece_1 = proc { "  #{get_square_at(space_index.next)}  |  #{get_square_at(space_index.next)}  " }
    line_piece_2 = proc { "|  #{get_square_at(space_index.next)}  " }

    v_frame = v_piece_1 + (v_piece_2 * board_size_multiplier)
    h_frame = h_piece_1 + (h_piece_2 * board_size_multiplier)
    line = proc do
      starting_index = space_index.peek
      ending_index = starting_index + line_size - 1

      this_line = line_piece_1.call
      this_line << (1..board_size_multiplier).to_a.collect { |_| line_piece_2.call }.join
      this_line <<  show_available_choices(starting_index..ending_index)
    end

    (line_size - 1).times do
      puts v_frame
      puts line.call
      puts v_frame
      puts h_frame
    end
    puts v_frame
    puts line.call
    puts v_frame
    puts ''
  end
# rubocop:enable Metrics/AbcSize

  def display_without_clearing
    display(clear_screen: false)
  end

  def clear_markers!
    keys = grid.keys
    keys.each { |key| grid[key] = Square.new }
  end

  def get_square_at(key)
    grid[key]
  end

  def get_markers_at(grid_locations)
    grid.values_at(*grid_locations).collect(&:marker)
  end

  def get_available_square_at(key)
    selected_square = get_square_at(key)
    selected_square if empty_squares.values.include?(selected_square)
  end

  def []=(num, marker)
    grid[num].update_marker marker
  end

  def empty_squares(range = nil)
    grid.select do |index, square|
      square.marker == Square::INITIAL_MARKER &&
      if range
        range.include?(index)
      else
        true
      end
    end
  end

  def show_available_choices(range = nil)
    all_empty_squares = empty_squares(range).keys
    last_empty_square = all_empty_squares.pop if all_empty_squares.size > 1

    options = if last_empty_square
                "#{all_empty_squares.join(', ')}" + " or #{last_empty_square}"
              else
                all_empty_squares[0].to_s
              end

    return " <<<  (#{options})" unless options.empty?
    return ''
  end
end

# A square stores the current state of the board at a particular location.

class Square
  include Messaging

  INITIAL_MARKER = ' '
  attr_reader :marker

  def initialize
    @marker = INITIAL_MARKER
  end

  def update_marker(value)
    @marker = value
  end

  def to_s
    marker
  end
end

# A player is an individual person or computer, with their own name, score and unique marker.

class Player
  include Messaging

  @@all = []
  @@markers_used = []

  attr_reader :marker, :name, :score, :type

  def initialize(marker = '', options = { is_human: false })
    @type = (options[:is_human] ? :human : :computer)
    self.name = (options[:is_human] ? '' : nil)
    @marker = choose_marker(marker)
    @score = 0
    @@all << self
    @@markers_used << self.marker
  end

  def self.all
    @@all
  end

  def self.next_player_marker
    @@markers_used.last.succ.upcase
  end

  def self.highest_scoring
    @@all.reduce([]) do |highest_player, player|
      if highest_player.empty? || highest_player.any? { |lp| player.score > lp.score }
        [player]
      elsif highest_player.any? { |lp| player.score == lp.score }
        highest_player + [player]
      else
        highest_player
      end
    end
  end

  def self.lowest_scoring
    @@all.reduce([]) do |lowest_player, player|
      if lowest_player.empty? || lowest_player.any? { |lp| player.score < lp.score }
        [player]
      elsif lowest_player.any? { |lp| player.score == lp.score }
        lowest_player + [player]
      else
        lowest_player
      end
    end
  end

  def to_s
    "#{name} (#{marker})"
  end

  def choose_marker(marker = '')
    if marker.empty?
      loop do
        prompt "Please choose a marker for #{name}"
        prompt_short ': '
        marker = gets.chomp
        if @@markers_used.include?(marker)
          prompt 'That marker is already taken'
          next
        elsif marker.empty?
          prompt "You didn't enter a marker"
          next
        end
        break
      end
      marker.upcase
    else
      (marker.upcase unless @@markers_used.include?(marker)) || Player.next_player_marker.upcase
    end
  end

  def name=(new_name = '')
    if new_name.nil?
      @name = %w(Billy Bob Buck Brian Buster).sample
    elsif new_name.empty?
      loop do
        prompt 'Please enter your name: '
        prompt_short ': '
        new_name = gets.chomp
        break unless new_name.empty?
        puts "Doesn't look like you typed your name."
      end
      @name = new_name
    end
  end

  def give_a_point
    @score += 1
  end
end

class Game
  # A game is an instance of board with a collection of players.

  include Messaging

  WINNING_SCORE = 5
  attr_reader :board, :primary_player, :primary_opponent, :current_player, :winner
  attr_accessor :match_has_ended

  def initialize
    self.match_has_ended = false
  end

  def build_board
    @board = Board.new
  end

  def choose_player_type
    loop do
      prompt 'Add 1) computer player, 2) human player:'
      player_type = gets.chomp.to_i

      return { is_human: false } if player_type == 1
      return { is_human: true } if player_type == 2

      prompt "You didn't choose 1 or 2:"
    end
  end

  def establish_players
    @primary_player = Player.new('', is_human: true)
    #@primary_player.name = ''
    @primary_opponent = Player.new('O', is_human: false)
    #@primary_opponent.name = nil

    prompt "#{primary_player.name}, you will be playing #{primary_opponent.name}"

    add_more_players?
  end

  def add_more_players?
    prompt 'Would you like to add a player? (y/n)'
    loop do
      answer = gets.chomp.downcase
      break if answer == 'n'
      if answer != 'y'
        prompt 'Please choose y or n'
        next
      end
      player_type = choose_player_type
      Player.new('', player_type)
      prompt 'Add another player? (y/n)'
    end
  end

  def display_welcome_message
    system 'clear'
    puts "\nWelcome to Tic Tac Toe!\n\n"
    prompt 'Hit > Enter < to begin!'
    gets.chomp
  end

  def refresh_game_display
    system 'clear'
    puts '###   Tic Tac Toe   ###'
    puts ''
    display_score
    board.display_without_clearing
  end

  def display_score
    each_players_score = Player.all.collect do |player|
                           "#{player}: #{player.score}"
    end.join(', ')

    puts 'SCORE: ' + each_players_score
  end

  def invalid_choice?(square)
    square != 'r' && !((1..board.grid.size).include?(square.to_i))
  end

  def available_choice?(square)
    board.empty_squares.values.include?(board.get_square_at(square.to_i)) ||
      square == 'r'
  end

  def lines_marked_with(current_player_count, opponent_count, options = { opponent_compare: :all })
    other_players = Player.all.select { |player| player != current_player }

    selected_squares = board.winning_lines.select do |winning_line|
                         winning_line_of_squares = board.grid.values_at(*winning_line)

                         case options[:opponent_compare]
                         when :all
                           other_players.all? do |other_player|
                             winning_line_of_squares.collect(&:marker).count(current_player.marker) >= current_player_count &&
                             winning_line_of_squares.collect(&:marker).count(other_player.marker) <= opponent_count
                           end
                         when :any
                           other_players.any? do |other_player|
                             winning_line_of_squares.collect(&:marker).count(Square::INITIAL_MARKER) == 1 &&
                             winning_line_of_squares.collect(&:marker).count(other_player.marker) == opponent_count
                           end
                         end
    end.flatten.uniq

    board.empty_squares.select do |position, _|
      selected_squares.include?(position)
    end.values
  end

  def winning_moves
    lines_marked_with(board.line_size - 1, 0)
  end

  def defensive_moves
    lines_marked_with(0, board.line_size - 1, opponent_compare: :any)
  end

  def offensive_moves
    best_offensive_lines.select do |squares|
      squares.marker == Square::INITIAL_MARKER
    end
  end

  def available_winning_lines
    board.winning_lines.map do |line|
      line_with_values = board.grid.values_at(*line)
      line_with_values if line_with_values.count do |square|
                            square.marker != current_player.marker &&
                            square.marker != Square::INITIAL_MARKER
                          end == 0
    end.compact
  end

  def best_offensive_lines
    available_winning_lines.reduce([[]]) do |best_lines, line|
      winning_line = best_lines.last.collect(&:marker).count(current_player.marker)
      contending_line = line.collect(&:marker).count(current_player.marker)
      if (contending_line == 0) || (winning_line > contending_line)
        best_lines
      elsif winning_line == contending_line
        best_lines << line
      else
        [line]
      end
    end.compact.flatten
  end

  def center_square
    if board.line_size.odd?
      board.get_available_square_at(board.grid.keys.reduce(:+) / board.grid.size)
    end
  end

  def current_player_moves
    human_moves if @current_player.type == :human
    computer_moves if @current_player.type == :computer
  end

  def computer_moves
    prompt "#{current_player.name}'s turn to move: >> Hit Enter <<"
    gets.chomp

    move = winning_moves.sample ||
           defensive_moves.sample ||
           center_square ||
           offensive_moves.sample ||
           board.empty_squares.values.sample

    move.update_marker(current_player.marker)
  end

  def human_moves
    prompt "#{current_player.name}, please choose a square (r to reset game)"
    prompt_short ': '
    square = human_choose_square
    if square.to_s.downcase == 'r'
      self.match_has_ended = true # refactor this?
    else
      board[square.to_i] = current_player.marker
    end
  end

  def human_choose_square
    loop do
      square = gets.chomp
      if invalid_choice?(square)
        print "That's not a valid choice"
        prompt "Try again"
        prompt_short ': '
        next
      end
      return square if available_choice?(square)
      prompt 'That space is already marked. Choose another.'
      prompt_short ': '
    end
  end

  def determine_starting_player
    next_players_turn(Player.lowest_scoring.sample)
  end

  def next_players_turn(specified_player = nil)
    player_list = Player.all

    if player_list.include?(specified_player)
      player_list.rotate! until player_list.first == specified_player
    else
      player_list.rotate!
    end

    @current_player = player_list.first
  end

  def identify_winner
    @winner = winner?
  end

  def winner?(players = nil)
    players = Player.all if players.nil?

    [players].flatten.find do |player|
      board.winning_lines.any? do |winning_line_locations|
        board.get_markers_at(winning_line_locations).count(player.marker) == board.line_size
      end
    end
  end

  def board_filled?
    board.empty_squares.empty?
  end

  def gridlock?
    Player.all.all? do |player|
      board.winning_lines.all? do |line|
        markers = board.get_markers_at(line)
        markers.any? do |marker|
          !([Square::INITIAL_MARKER, player.marker].include? marker)
        end
      end
    end
  end

  def display_result
    if winner
      prompt_long "#{winner.name} wins!"
    elsif gridlock?
      prompt_long 'Gridlock. Nobody will win.'
    else
      prompt_long "It's a draw."
    end
  end

  def update_score
    winner.give_a_point if winner
  end

  def reset_board
    board.clear_markers!
    @winner = nil
    self.match_has_ended = false
  end

  def play_again?
    prompt_short 'Would you like to play again? (y/n): '
    answer = ''
    loop do
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      prompt_short 'Please choose y or n: '
    end

    (answer == 'y')
  end

  def game_winner?
    Player.all.any? { |player| player.score == WINNING_SCORE }
  end

  def display_winner_message
    prompt "#{winner.name} has won the game!"
  end

  def display_goodbye_message
    puts "\nThanks for playing! Bye...\n"
  end

  def play
    display_welcome_message
    establish_players
    build_board
    loop do
      reset_board
      refresh_game_display
      determine_starting_player
      loop do
        current_player_moves
        refresh_game_display
        break if winner? || board_filled? || gridlock? || match_has_ended
        next_players_turn
      end
      identify_winner
      display_result
      update_score
      if game_winner?
        display_winner_message
        break
      end
      break unless play_again?
    end
    display_goodbye_message
  end
end

Game.new.play
