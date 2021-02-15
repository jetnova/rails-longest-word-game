require 'open-uri'

class GamesController < ApplicationController
  def new
    @grid = []
    10.times do
      @grid << ('a'..'z').to_a.sample
    end
  end

  def score
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @word = params[:word].downcase
    @grid = params[:grid].split(' ')

    if rogue_letters? || overused_letters?
      @message = "Sorry, but '#{@word}' cannot be built out of #{@grid}."
      return @message
    end

    return @message = "Sorry, but '#{@word}' does not seem to be a valid English word..." unless valid_word?

    calculate_score
  end

  # method to check whether each letter used in the attempt is within the user's grid of letters
  def rogue_letters?
    @word.split('').each do |letter|
      return true unless @grid.include?(letter)
    end
    false
  end

  def overused_letters?
    # initialise hashes to hold letter counts
    word_counts = Hash.new(0)
    grid_counts = Hash.new(0)
    # populate the letter count hashes
    @word.split('').each { |letter| word_counts[letter.to_sym] += 1 }
    @grid.each { |letter| grid_counts[letter.to_sym] += 1 }
    # return true if a letter is found to be overused by iterating through hashes
    word_counts.each do |letter, count|
      return true if count > grid_counts[letter.to_sym]
    end
    false
  end

  def valid_word?
    api_url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    words_json = open(api_url).read
    response = JSON.parse(words_json)
    response['found'] ? true : false
  end

  def calculate_score
    @message = "Congratulations! '#{@word.capitalize}' is a valid English Word"
    # initialise score to 0 for failed cases
    @score = 0
    @score = (@word.length / (@end_time - @start_time)) * 100
  end
end
