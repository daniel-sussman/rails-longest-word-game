require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    cookies[:user_score] ||= { value: 0, expires: 1.hour.from_now }
    cookies[:user_games] ||= { value: 0, expires: 1.hour.from_now }

    @letters = Array.new(10) { [*('A'..'Z')].sample }
  end

  def score
    @word = params[:word].downcase
    @word_valid = word_valid?(@word, params[:letters].downcase.split(' '))
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    URI.open(url) do |response|
      @word_response = JSON.parse(response.read)
      @word_in_dict = @word_response['found']
    end
    @score = @word_valid && @word_in_dict ? @word.size ** 2 : 0;
    cookies[:user_score] = cookies[:user_score].to_i + @score
    cookies[:user_games] = cookies[:user_games].to_i + 1
  end

  def word_valid?(word, letters)
    word.split('').all? do |letter|
      valid = letters.include?(letter)
      index = letters.index(letter)
      letters.delete_at(index) if index
      valid
    end
  end
end
