require 'open-uri'
require 'json'

class GameController < ApplicationController
  def game
    @grid =(('A'..'Z').to_a * 2).sample(12).join(" ")
    @start_time = Time.now
  end

  def score
    @grid = params[:grid]
    @attempt = params[:attempt]
    @start_time = params[:start_time].to_time
    @end_time = Time.now
    # @time_elapsed = @start_time.to_i - @end_time.to_i
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  def translate(attempt)
    apikey = "01cc10e4-adaf-4b3a-af59-f5d67f8b6bb4"
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{apikey}&input=#{attempt}"
    word_serialized = open(url).read
    word = JSON.parse(word_serialized)
    word["outputs"][0]["output"]
  end

  # # p translate("yes")

  def real_word?(attempt)
    words = File.read('/usr/share/dict/words').downcase.split("\n")
    words.include?(attempt)
  end

  # p real_word?("yes")

  def attempt_in_grid?(attempt, grid)
    downcased_grid = grid.downcase.split("")
    split_attempt = attempt.split("")
    split_attempt.all? { |e| downcased_grid.include?(e)}
  end

  def time_elapsed(start_time, end_time)
    end_time - start_time
  end

  def calc_score(attempt, grid, start_time, end_time)
    # if attempt_in_grid?(attempt, grid) == false || real_word?(attempt) == false
    #   return 0
    (attempt.length * 10) - time_elapsed(start_time, end_time)
  end

  # p calc_score("kin", ["K", "I", "N"], 23, 10)

  def message_feed(attempt, grid, start_time, end_time)
    if attempt_in_grid?(attempt, grid) == false
      return "Your word is not in the grid"
    elsif calc_score(attempt, grid, start_time, end_time) > 0
      return "well done"
    else
      return "No bueno."
    end
  end


  def run_game(attempt, grid, start_time, end_time)
    # arr = JSON.parse(grid)
    # p arr
    return { score: 0, message: "not in the grid" } unless attempt_in_grid?(attempt, grid)
    return { score: 0, message: "not an english word" } unless real_word?(attempt)
    {
      translation: translate(attempt),
      score: calc_score(attempt, grid, start_time, end_time),
      message: message_feed(attempt, grid, start_time, end_time),
      time: time_elapsed(start_time, end_time)
    }
  end
end
