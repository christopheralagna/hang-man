require 'pry'
require 'json'

class Game
  attr_accessor :secret_word, :hanged_man_displays, :completion_status, :incorrect_guesses, :incorrect_letters, :total_guesses, :saved_games

  def initialize(secret_word, hanged_man_displays, completion_status = Array.new(secret_word.length, ' _ '), incorrect_guesses = 0, incorrect_letters = [], total_guesses = 7, saved_games = [])
    @secret_word = secret_word
    @hanged_man_displays = hanged_man_displays
    @completion_status = completion_status
    @incorrect_guesses = incorrect_guesses
    @incorrect_letters = incorrect_letters
    @total_guesses = total_guesses
    @saved_games = saved_games
  end

  def start()
    puts "\n\nIf you would like to start a new game, press '1'"
    puts "Otherwise, if you would like to load a game you previously saved, press '2'"
    response = gets.chomp
    unless response == '1' || response == '2'
      puts "\nPlease enter a valid number"
      response = gets.chomp
    end
    if response == '1'
      welcome()
    elsif response == '2'
      Game.load()
    end
  end

  def save()
    string = JSON.dump ({
      :secret_word => @secret_word,
      :hanged_man_displays => @hanged_man_displays,
      :completion_status => @completion_status,
      :incorrect_guesses => @incorrect_guesses,
      :incorrect_letters => @incorrect_letters,
      :total_guesses => @total_guesses
    })
    save_directory = File.open('saved_games.txt', 'w')
    save_directory.write string
    puts "\n\nThanks for now!\n"
    exit
  end

  def self.load()
    string = File.open('saved_games.txt', 'r').readlines.join('')
    data = JSON.load(string)
    resumed_game = self.new(data['secret_word'], data['hanged_man_displays'], data['completion_status'], data['incorrect_guesses'], data['incorrect_letters'], data['total_guesses'], data['saved_games'])
    File.open('saved_games.txt', 'w').write ""
    puts "\n\nWelcome back!\n"
    resumed_game.display_hanged_man()
    resumed_game.round()
  end

  def welcome()
    puts "\n\n\nwelcome to Hang Man!"
    puts "\nSelect letters to try and guess the secret word"
    puts "\nFail to do so in the given number of tries, and you will be a hanged-man (OH NO!)"
    sleep(2)
    round()
  end

  def round()
    guess = get_guess()
    determine_accuracy(guess)
    display_hanged_man()
    game_status()
  end

  def display_hanged_man()
    for i in 0..@total_guesses do
      if i == @incorrect_guesses
        puts "\n\n#{@hanged_man_displays[i]}\n\n"
      end
    end
    puts "Incorrect Letters : #{@incorrect_letters.join(' ')}"
  end

  def get_guess()
    puts "\n\nPlease guess a letter...\t\t (or enter '1' to save your game)"
    guess = gets.chomp()
    if guess == '1'
      save()
    end
    until guess.kind_of?(String)
      puts "Please enter a valid letter"
      guess = gets.chomp().to_s
    end
    until !@incorrect_letters.include?(guess)
      puts "You already tried that letter!"
      guess = gets.chomp()
    end
    return guess
  end

  def determine_accuracy(guessed_letter)
    secret_word_array = @secret_word.split('')
    if @secret_word.include?(guessed_letter)
      puts "\nYou guessed [#{guessed_letter}] correctly!\n"
      for i in 0..@secret_word.length-1 do
        if guessed_letter == secret_word_array[i]
          @completion_status[i] = " #{guessed_letter} "
        else
          unless @completion_status[i] != " _ "
          @completion_status[i] = " _ "
          end
        end
      end
    else
      @incorrect_letters.push(guessed_letter)
      puts "\nYou guessed [#{guessed_letter}] incorrectly!\n"
      @incorrect_guesses += 1
    end
    puts @completion_status.join('')
  end

  def game_status()
    if @incorrect_guesses == @total_guesses
      game_end('loser')
    elsif @completion_status.map{ |letter| letter.strip }.join() == @secret_word
      game_end('winner')
    else
      puts "\nnext round..."
      round()
    end
  end

  def game_end(status)
    if status == 'loser'
      puts "\nYou lose!"
      puts "\nThe word was #{@secret_word}!\n"
    elsif status == 'winner'
      puts "\nYou win!\n"
    end
  end

end

def get_random_word()
  dictionary = File.open("dictionary.txt", 'r').readlines
  return dictionary[rand(dictionary.length)].strip
end

hanged_man_displays = [
  #0 
"  __________  
   |        |  
            |  
            |  
            |  
            |  
            |  
   _________|  ",
#1
"  __________  
   |        |  
   O        |  
            |  
            |  
            |  
            |  
   _________|  ",
#2
"  __________  
   |        |  
   O        |  
   |        |  
            |  
            |  
            |  
   _________|  ",
#3
"  __________  
   |        |  
   O        |  
   |        |  
   |        |  
            |  
            |  
   _________|  ",
#4
"  __________  
   |        |  
   O        |  
   |/       |  
   |        |  
            |  
            |  
   _________|  ",
#5
'   __________  
    |        |  
    O        |  
   \|/       |  
    |        |  
             |  
             |  
    _________|  ',
#6
'  __________  
   |        |  
   O        |  
  \|/       |  
   |        |  
    \       |  
            |  
   _________|  ',
#7
'  __________  
   |        |  
   O        |  
  \|/       |  
   |        |  
  / \       |  
            |  
   _________|  ',
]

random_word = get_random_word()
new_game = Game.new(random_word, hanged_man_displays)
new_game.start()
