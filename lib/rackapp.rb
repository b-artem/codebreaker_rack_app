# require 'erb'
require 'codebreaker_artem/game'
require 'codebreaker_artem/validator'
require 'yaml'
require './lib/utils'

# require 'pry-byebug'

class RackApp
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @sessions = Utils.read_sessions || {}
  end

  def response
    case @request.path
    when '/' then home
    when '/start' then start
    when '/submit_guess' then submit_guess
    when '/hint' then hint
    else Rack::Response.new('Not found', 404)
    end
  end

  # def word
  #   @request.cookies['word'] || 'Nothing'
  # end

  def game
    sid = @request.session['session_id']
    game = @sessions[sid]
    game.inspect.tr('#<>::@', '') || 'No game yet'
  end

  def guess_count
    find_game
    return '1' unless @game
    guess_count = @game.guess_count
    return guess_count if guess_count == CodebreakerArtem::Game::MAX_GUESS_NUMBER
    @game.guess_count + 1
  end

  def guess_log
    guess_log = @request.cookies['guess_log'] || 'No guesses yet'
    guess_log.split("\n")
  end

  def guess_left
    find_game
    return CodebreakerArtem::Game::MAX_GUESS_NUMBER unless @game
    CodebreakerArtem::Game::MAX_GUESS_NUMBER - @game.guess_count
  end

  private

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def home
    find_game
    return Rack::Response.new(render('index.html.erb')) if @game
    start
  end

  def start
    Rack::Response.new do |response|
      game = CodebreakerArtem::Game.new
      game.start
      @request.session['init'] = true
      sid = @request.session['session_id']
      response.set_cookie('guess_log', '')
      response.set_cookie('secret_number', '')
      response.set_cookie('secret_position', '')
      save_game(sid, game)
      Utils.save_sessions @sessions
      response.redirect('/')
    end
  end

  def submit_guess
    Rack::Response.new do |response|
      find_game
      max_attempts = CodebreakerArtem::Game::MAX_GUESS_NUMBER
      guess = @request.params['guess']
      if Validator.code_valid?(guess) && @game.guess_count < max_attempts
        mark = @game.mark_guess(guess)
        @guess_log = @request.cookies['guess_log']
        @guess_log ||= []
        @guess_log << "#{guess}: #{mark}\n"
        response.set_cookie('guess_log', @guess_log)
        Utils.save_sessions @sessions
      end

      # return CLI.win(input, game.score) if Validator.win_mark?(mark)
      # return CLI.lose(game.secret_code, game.score, MAX) if game.guess_count >= MAX
      response.redirect('/')
    end
  end

  def hints_left
    return 'no' unless @request.cookies['secret_number']
    return 'no' unless @request.cookies['secret_number'] == ''
    '1'
  end

  def secret_number
    @request.cookies['secret_number']
  end

  def secret_position
    @request.cookies['secret_position']
  end

  def show_hint?
    return unless hint = @request.cookies['secret_number']
    return if hint == ''
    true
  end

  def hint
    find_game
    return Rack::Response.new { |resp| resp.redirect('/') } unless hint = @game.hint
    Rack::Response.new do |response|
      response.set_cookie('secret_number', hint[0].to_s)
      response.set_cookie('secret_position', (hint[1] + 1).to_s)
      Utils.save_sessions @sessions
      response.redirect('/')
    end
  end

  def find_game
    sid = @request.session['session_id']
    @game = @sessions[sid]
  end

  def save_game(sid, game)
    @sessions[sid] = game
  end
end
