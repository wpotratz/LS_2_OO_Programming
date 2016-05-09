# training/launchschool/5_larger_programs/oo_twenty1.rb
# Notes:
# I tried my best to apply my understanding of oo ruby, and also tried to be creative.
# I feel like I was very inconsistent with my input prompts and validation. I'm sure I'll get a feel for the best language use eventually.
# line 214, 222, 308, 312. I'm not completely confident the usage of private/protected is necessary here. The idea was to prevent the value of a hidden card from being accessible.
# line 361: #show_each_players_hand and included methods will need to be adjusted if multiple players are added, so multiple players are shown side-by-side.
# line 440: There are several conditions like this. Not sure if there's a simpler way to compare the results of multiple methods on the same object.

require 'pry'

module Prompts
  def y_n_prompt
    prompt_short ': '
    response = gets.chomp
    return response if %w(y n).include?(response)
  end

  def name_prompt
    loop do
      prompt 'Please enter a name for this player.'
      prompt_short ': '
      answer = gets.chomp
      return answer unless answer.empty?
      prompt "You didn't type anything."
    end
  end
end

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

class Player
  include Messaging, Prompts

  STARTING_BANK_AMOUNT = 500

  attr_accessor :hand, :status
  attr_reader :dealer, :type, :name, :bank, :bet

  def initialize(type, dealer = false)
    self.hand = []
    @type = type
    @dealer = (dealer ? true : false)
    @name = choose_name
    self.status = nil
    @bank = STARTING_BANK_AMOUNT
  end

  def show_bank
    "$ #{bank}"
  end

  def show_bet
    "$ #{bet}"
  end

  def choose_name
    if dealer
      'Dealer'
    elsif type == :computer
      %w(Billy Beatrice Betty Bob Bruno Ben Bonnie).sample
    elsif type == :human
      name_prompt
    end
  end

  def make_bet!
    return nil if dealer

    if bank == 0
      prompt 'You are broke my friend.'
    elsif bank > 0
      loop do
        prompt "Please make your bet (up to $ #{bank})"
        prompt_short ': '
        valid_bet = validate_bet(gets.chomp)
        next unless valid_bet
        self.bet = valid_bet
        update_bank!(bet, action: :take_bet)
        break
      end
    end
  end

  def validate_bet(input)
    if (1..bank).include?(input.to_i)
      input.to_i
    elsif input.empty?
      puts "You didn't make a bet!"
      nil
    elsif input.to_i > bank
      prompt "You don't have that much money!"
      nil
    end
  end

  def reset_bet!
    @bet = nil
  end

  def reset_status!
    @status = nil
  end

  def reset!
    reset_bet!
    self.status = :reset
    reset_bank!
  end

  def deal_cards(quantity, source_deck, options = { visible: true })
    quantity.times do
      new_card = source_deck.cards.pop
      new_card.visible = options[:visible]
      hand << new_card
    end
  end

  def show_cards
    puts hand.map { |card| Card::FRAME[card.suit_shown][0] }.join(' ')
    puts hand.map { |card| Card::FRAME[card.suit_shown][1] }.join(' ')
    puts (hand.map do |card|
      line = Card::FRAME[card.suit_shown][2]
      line += card.show_value
      line += Card::FRAME[card.suit_shown][3]
      line
    end.join(' '))
    puts hand.map { |card| Card::FRAME[card.suit_shown][4] }.join(' ')
    puts hand.map { |card| Card::FRAME[card.suit_shown][5] }.join(' ')
  end

  def hand_total
    values = hand.collect(&:value_shown)
    score = values.reduce(0) do |total, card_face|
      total + face_value(card_face)
    end

    values.count { |value| value == 'A' }.times do
      score += 10 if (score + 10 <= Game::WINNING_TOTAL)
    end

    score
  end

  def show_hand_total
    puts "TOTAL:  #{hand_total}"
  end

  def face_value(input)
    if input == 'X'
      0
    elsif input == 'A'
      1
    elsif input.to_i == 0
      10
    else
      input.to_i
    end
  end

  def show_summary
    print "#{name}".center(7)
    puts "- BANK:  #{show_bank}"
    puts "CURRENT WAGER:  #{show_bet}" unless bet.nil?
  end

  def reveal_hidden_cards!
    hand.each { |card| card.visible = true }
  end

  def show_status
    case status
    when :win then puts "#{name} wins with #{hand_total}!"
    when :lose then puts 'The dealer wins.'
    when :bust then puts "#{name} busts!"
    when :push then puts "It's a push."
    when :blackjack then puts "#{name} has blackjack!"
    end
  end

  def blackjack?
    hand_total == Game::WINNING_TOTAL
  end

  def bust?
    hand_total > Game::WINNING_TOTAL
  end

  def hit_minimum?
    hand_total >= Game::DEALER_MINIMUM_TOTAL
  end

  def update_bank!(amount, options) # add error checking
    case options[:action]
    when :payout then self.bank += (amount * 2)
    when :return_wager then self.bank += amount
    when :take_bet then self.bank -= amount
    end
  end

  private

  def bank=(amount)
    @bank = amount
  end

  def reset_bank!
    self.bank = STARTING_BANK_AMOUNT
  end

  def bet=(amount)
    @bet = amount
  end
end

class Deck
  include Messaging, Prompts

  attr_accessor :cards

  def initialize(number_of_decks)
    self.cards = build_deck(number_of_decks)
  end

  def build_deck(number_of_decks)
    cards = []
    number_of_decks.times do
      Card::SUITS.each do |suit|
        Card::VALUES.each do |value|
          cards << Card.new(suit, value)
        end
      end
    end
    cards
  end
end

class Card
  include Messaging, Prompts

  SUITS = %w(S D H C)
  VALUES = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  FRAME = {
    'H' => [' ____ ',
            '|/\\/\\|',
            '|\\', '/|',
            '| \\/ |',
            '|____|'],
    'S' => [' ____ ',
            '| /\\ |',
            '|(', ')|',
            '| || |',
            '|____|'],
    'D' => [' ____ ',
            '| /\\ |',
            '|(', ')|',
            '| \\/ |',
            '|____|'],
    'C' => [' ____ ',
            '| () |',
            '|(', ')|',
            '| || |',
            '|____|'],
    'X' => [' ____ ',
            '|XxXx|',
            '|xXxX|', '',
            '|XxXx|',
            '|xXxX|']
  }

  attr_reader :visible, :suit_shown, :value_shown

  def initialize(suit, value, options = { visible: true })
    @suit = suit
    @value = value
    self.visible = options[:visible]
  end

  def show_value
    if suit_shown == 'X'
      ''
    elsif value_shown.size == 1
      " #{value_shown}"
    elsif value_shown.size == 2
      value_shown
    end
  end

  def visible=(options)
    @visible = options
    @suit_shown = (visible ? suit : 'X')
    @value_shown = (visible ? value : 'X')
  end

  private

  def suit
    @suit
  end

  def value
    @value
  end
end

class Game
  include Messaging, Prompts

  WINNING_TOTAL = 21
  DEALER_MINIMUM_TOTAL = 17

  attr_writer :players
  attr_accessor :dealer
  attr_reader :current_deck, :current_player

  def initialize
    @current_deck = new_deck
    self.players = []
  end

  def current_player=(player)
    @current_player = player
    current_player.reveal_hidden_cards! if current_player.dealer
  end

  def initiate_players
    self.dealer = Player.new(:computer, true)
    @players << Player.new(:human)
    # add_players?
  end

  def welcome_message
    system 'clear'
    prompt "Welcome to TwentyOne! Let's play."
  end

  def refresh_display
    show_dealers_hand
    show_each_players_hand
  end

  def show_dealers_hand
    system 'clear'
    puts 'Dealer:'
    dealer.show_cards
    dealer.show_hand_total
    puts ''
  end

  def show_each_players_hand
    puts 'Players:'
    players.each do|player|
      player.show_summary
      player.show_cards
      player.show_hand_total
      puts ''
      dealer.show_status
      player.show_status
    end
    puts ''
  end

  def new_deck(quantity = 2)
    new_deck = Deck.new(quantity)
    2.times { new_deck.cards.shuffle! }

    new_deck
  end

  def reset_discard_and_shuffle
    return_all_cards!
    shuffle_deck!
    players.each do |player|
      player.reset_status!
      player.reset_bet!
    end
    dealer.status = nil
  end

  def players
    @players.select { |player| player.status != :out }
  end

  def players_bet
    system 'clear'
    players.each do |player|
      player.show_summary
      player.make_bet!
    end
  end

  def return_all_cards!
    all_players = players + [dealer]

    all_players.each do |player|
      player.reveal_hidden_cards!
      current_deck.cards << player.hand.pop until player.hand.empty?
    end
  end

  def shuffle_deck!
    2.times { current_deck.cards.shuffle! }
  end

  def deal_players
    dealer.deal_cards(1, current_deck, visible: false)
    dealer.deal_cards(1, current_deck)
    players.each { |player| player.deal_cards(2, current_deck) }
    refresh_display
  end

  def each_players_turn
    players.each do |player|
      self.current_player = player
      refresh_display
      prompt "#{current_player.name}'s turn!"
      player_takes_turn
    end
  end

  def player_takes_turn
    loop do
      prompt "#{current_player.name}, would you like to hit or stay? (h/s)"
      player_choice = hit_or_stay
      break if player_choice == 's'

      hit if player_choice == 'h'
      refresh_display
      break if current_player.bust? || current_player.blackjack?
    end
  end

  def hit_or_stay
    valid_answer = nil
    loop do
      prompt_short ': '
      valid_answer = gets.chomp.downcase
      break if %w(h s).include?(valid_answer)
      prompt "That's not a valid choice. Try again."
    end

    valid_answer
  end

  def hit
    current_player.deal_cards(1, current_deck)
  end

  def natural_blackjack
    if players.any? { |player| player.blackjack? && player.hand.size == 2 }
      self.current_player = dealer
      refresh_display
      return true
    end

    nil
  end

  def all_players_bust?
    players.all?(&:bust?)
  end

  def all_players_hit_blackjack?
    if players.all?(&:blackjack?)
      dealer.reveal_hidden_cards!
      refresh_display
      return true
    end

    nil
  end

  def dealers_turn
    self.current_player = dealer
    hit_until_bust_or_minimum
  end

  def hit_until_bust_or_minimum
    prompt "Dealer's turn. < Enter to continue >"
    gets.chomp
    refresh_display
    until current_player.bust? || current_player.blackjack? || current_player.hit_minimum?
      prompt 'Dealer will take another card. < Hit Enter >'
      gets.chomp
      hit
      refresh_display
    end
  end

  def identify_winners
    players.each do |player|
      self.current_player = player
      set_player_status!
    end

    dealer.status = :blackjack if dealer.blackjack?
    dealer.status = :bust if dealer.bust?
  end

  def set_player_status!
    if current_player.bust?
      current_player.status = :bust
    elsif current_player.hand_total == dealer.hand_total
      current_player.status = :push
    elsif current_player.blackjack?
      current_player.status = :blackjack
    elsif (current_player.hand_total > dealer.hand_total) || dealer.bust?
      current_player.status = :win
    else
      current_player.status = :lose
    end
  end

  def display_results
    refresh_display
  end

  def payout
    players.each do |player|
      if [:blackjack, :win].include?(player.status)
        player.update_bank!(player.bet, action: :payout)
      elsif player.status == :push
        player.update_bank!(player.bet, action: :return_wager)
      end
    end
  end

  def all_players_out?
    players.empty?
  end

  def play_again?
    valid_answer = ''
    loop do
      prompt "#{current_player.name}, you have #{current_player.show_bank}. Play another game? (y/n)"
      valid_answer = y_n_prompt
      break if valid_answer
      prompt "That's not a valid answer. Try again."
    end

    (valid_answer == 'y')
  end

  def handle_broke_players!
    players.each do |player|
      next if player.bank > 0

      player.status = :out_of_money
      prompt "#{player.name}, you are broke my friend."

      player_decision = buy_back_in?
      player.reset! if player_decision == 'y'
      player.status = :out if player_decision == 'n'
    end
  end

  def buy_back_in?
    player_decision = nil
    until player_decision
      prompt 'Want to buy in again? (y/n)'
      player_decision = y_n_prompt
    end

    player_decision
  end

  def game_over?
    players.none? { |player| player.status == :reset } &&
      (all_players_out? || !play_again?)
  end

  def goodbye_leaving_players_message
    players.select { |player| player.status == :out }.each do |player|
      prompt "#{player.name}, tough luck. Play again soon!"
    end
  end

  def goodbye_message
    players.each do |player|
      if player.bank > Player::STARTING_BANK_AMOUNT
        prompt "Nice work #{player.name}! Don't spend it all in one place!"
      elsif player.bank == Player::STARTING_BANK_AMOUNT
        prompt "#{player.name}, you still have your #{player.show_bank}. No harm no foul, right?"
      else
        prompt "Well #{player.name}, at least you're leaving with something."
      end
    end
    prompt 'Thanks for playing! Goodbye.'
  end

  def play
    welcome_message
    initiate_players
    loop do
      loop do
        reset_discard_and_shuffle
        players_bet
        deal_players
        break if natural_blackjack
        each_players_turn
        break if all_players_bust?
        dealers_turn
        break
      end
      identify_winners
      display_results
      payout
      handle_broke_players!
      goodbye_leaving_players_message
      break if game_over?
    end
    goodbye_message
  end
end

current_game = Game.new
current_game.play
